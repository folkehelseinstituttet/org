# org
[![Build Status](https://travis-ci.com/folkehelseinstituttet/org.svg?branch=master)](https://travis-ci.com/folkehelseinstituttet/org)
[![codecov](https://codecov.io/gh/folkehelseinstituttet/org/branch/master/graph/badge.svg)](https://codecov.io/gh/folkehelseinstituttet/org)

## fhiverse

The `fhiverse` is a set of R packages developed by the Norwegian Institute of Public Health to help solve problems relating to:

- analysis planning (especially for making graphs/tables for reports)
- file structures in projects
- structural data in Norway (e.g. maps, population, redistricting)
- convenience functions for Norwegian researchers (e.g. Norwgian formatting, Norwegian characters)
- styleguides/recommendations for FHI employees

If you want to install the dev versions (or access packages that haven't been released on CRAN), run `usethis::edit_r_profile()` to edit your `.Rprofile`. Then write in:

```
options(repos=structure(c(
  FHI="https://folkehelseinstituttet.github.io/drat/",
  CRAN="https://cran.rstudio.com"
)))
```

Save the file and restart R. This will allow you to install `fhiverse` packages from the FHI registry.

Current `fhiverse` packages are:

- [org](https://folkehelseinstituttet.github.io/org)
- [plnr](https://folkehelseinstituttet.github.io/plnr)
- [spread](https://folkehelseinstituttet.github.io/spread)
- [fhidata](https://folkehelseinstituttet.github.io/fhidata)
- [fhiplot](https://folkehelseinstituttet.github.io/fhiplot)
- [fhi](https://folkehelseinstituttet.github.io/fhi)

## Concept 

The concept behind `org` is fairly simple - most analyses have three main sections:

- code
- results
- data

Yet each of these sections have extremely different requirements.

Code should:

- Be version controlled
- Be publically accessible
- Have 1 analysis pipeline that logically and sequentially details all steps of the data cleaning, analysis, and result generation

Results should:

- Be immediately shared with close collaborators
- Have each set of results saved and accessible, so that you can see how your results have changed over time (i.e. "if we run the code today, do we get similar results to yesterday?")

Data should:

- Be encrypted (if sensitive)
- Not stored on the cloud (if sensitive)

## Code

### org::initialize_project

`org::initialize_project` takes in 2+ arguments. It then saves its results (i.e. folder locations) in `org::project`, which you will use in all of your subsequent code.

`home` is the location of `Run.R` and the `code/` folder. It will be accessible via `org::project$home` (but you will rarely need this).

`results` is your results folder. It will create a folder inside `results` with today's date and it will be accessible via `org::project$results_today` (this is where you will store all of your results). Because the folder's name is today's date, this means that it automatically archives one copy of results per day. This allows you and your collaborators to easily check and see how the results have changed over time.

`...` you can specify other folders if you want, and they will also be accessible via `org::project`. Some suggested ones are `raw` (raw data) and `clean` (clean data).

### Run.R 

`Run.R` will be your masterfile. It will sequentially run through every part of your analysis:

- data cleaning
- analysis
- result generation

You will not have any other masterfiles, as this creates confusion when you need to return to your code 2 years later.

All sections of code (e.g. data cleaning, analyses for table 1, analyses for table 2, result generation for table 1, sensitivity analysis 1, etc) will be encapsulated in functions that live in the `code` folder.

An example `Run.R` might look like this:

```
# Define the following 'special' locations:
# 'home' (i.e. Run.R and code/ folder)
# 'results' (i.e. A folder with today's date will be created here)

# Define any other locations you want:
# 'raw' (i.e. raw data)

# remember to set `create_folders` = TRUE
org::initialize_project(
  home = "/git/analyses/2019/analysis3/",
  results = "/dropbox/analyses_results/2019/analysis3/"
  raw = "/data/analyses/2019/analysis3/",
  create_folders = TRUE
)

# It is a good practice to describe how the archived
# results are changing from day-to-day.
#
# We recommend saving this information as a text file
# stored in the `org::project$results` folder.
txt <- glue::glue("
  2019-01-01:
    Included:
    - Table 1
    - Table 2
  
  2019-02-02:
    Changed Table 1 from mean -> median
  
", .trim=FALSE)

org::write_text(
  txt = txt,
  file = fs::path(org::project$results, "info.txt")
)

library(data.table)
library(ggplot2)

# This function would access data located in org::project$raw
d <- clean_data()

# These functions would save results to org::project$results_today
table_1(d)
figure_1(d)
figure_2(d)
```

### code/

All of your functions should be defined in `org::project$home/code`. The function `org::initialize_project` automatically sources all of the R scripts in `org::project$home/code`, making them available for use.

## Solutions

### Best Practice

Our (very opinionated) solution is as follows:

Code should be stored in Github. Data should be stored locally in an encrypted volume. Results should be stored on Dropbox, with the results for each day stored in a different folder.

```
# code goes here:
git
  +-- analyses
             +-- 2018
             |      +-- analysis1 <- org::project$home
             |      |           +-- Run.R
             |      |           +-- code
             |      |                  +-- CleanData.R
             |      |                  +-- Descriptives.R
             |      |                  +-- Analysis1.R
             |      |                  +-- Graphs1.R
             |      +-- analysis2 <- org::project$home
             |                  +-- Run.R
             |                  +-- code
             |                         +-- CleanData.R
             |                         +-- Descriptives.R
             |                         +-- Analysis1.R
             |                         +-- Graphs1.R
             +-- 2019
                    +-- analysis3 <- org::project$home
                                +-- Run.R
                                +-- code
                                       +-- CleanData.R
                                       +-- Descriptives.R
                                       +-- Analysis1.R
                                       +-- Graphs1.R
                                       
# results goes here:
dropbox
  +-- analyses_results
             +-- 2018
             |      +-- analysis1 <- org::project$results
             |      |           +-- 2018-03-12 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-03-15 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-03-18 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             |      |           +-- 2018-06-18 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- table2.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             |      +-- analysis2 <- org::project$results
             |      |           +-- 2018-06-09 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-12-15 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2019-01-18 <- org::project$results_today
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             +-- 2019
                    +-- analysis3 <- org::project$results
                    |           +-- 2019-06-09 <- org::project$results_today
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           +-- 2019-12-15 <- org::project$results_today
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           +-- 2020-01-18 <- org::project$results_today
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           |            +-- figure2.png

# data goes here:
data
  +-- analyses
             +-- 2018
             |      +-- analysis1 <- org::project$raw
             |      |           +-- data.xlsx
             |      +-- analysis2 <- org::project$raw
             |      |           +-- data.xlsx
             +-- 2019
                    +-- analysis3 <- org::project$raw
                                +-- data.xlsx

```

Suggested code for `Run.R`:

```
org::initialize_project(
  home = "/git/analyses/2019/analysis3/",
  results = "/dropbox/analyses_results/2019/analysis3/",
  raw = "/data/analyses/2019/analysis3/",
  create_folders = TRUE
)
```

### One Folder on a Shared Network Drive

If you only have one folder on a shared network drive, without access to github or dropbox, then we propose the following solution:

```
# code goes here:
project_name <- org::project$home
  +-- Run.R
  +-- code
  |      +-- CleanData.R
  |      +-- Descriptives.R
  |      +-- Analysis1.R
  |      +-- Graphs1.R
  +-- results <- org::project$results
  |         +-- 2018-03-12 <- org::project$results_today
  |         |            +-- table1.xlsx
  |         |            +-- figure1.png
  |         +-- 2018-03-12 <- org::project$results_today
  |         |            +-- table1.xlsx
  |         |            +-- figure1.png
  +-- data_raw <- org::project$raw
  |          +-- data.xlsx
```

Suggested code for `Run.R`:

```
org::initialize_project(
  home = "/network/project_name/",
  results = "/network/project_name/results/",
  raw = "/network/project_name/data_raw/",
  create_folders = TRUE
)
```

### RMarkdown

If you only have one folder on a shared network drive, without access to github or dropbox, and you would like to create an RMarkdown document, then we propose the following solution:

```
# code goes here:
project_name <- org::project$home
  +-- Run.R
  +-- code
  |      +-- CleanData.R
  |      +-- Descriptives.R
  |      +-- Analysis1.R
  |      +-- Graphs1.R
  +-- paper
  |      +-- paper.Rmd
  +-- results <- org::project$results
  |         +-- 2018-03-12 <- org::project$results_today
  |         |            +-- table1.xlsx
  |         |            +-- figure1.png
  |         +-- 2018-03-12 <- org::project$results_today
  |         |            +-- table1.xlsx
  |         |            +-- figure1.png
  +-- data_raw <- org::project$raw
  |          +-- data.xlsx
```

Suggested code for `Run.R`:

```
# Initialize the project

org::initialize_project(
  home = "/network/project_name/",
  results = "/network/project_name/results/",
  paper = "/network/paper/",
  raw = "/network/project_name/data_raw/",
  create_folders = TRUE
)

# do some analyses here

# render the paper

rmarkdown::render(
  input = fs::path(org::project$paper,"paper.Rmd"),
  output_dir = org::project$results_today,
  quiet = F
)
```

