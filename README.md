# org
[![Build Status](https://travis-ci.org/raubreywhite/org.svg?branch=master)](https://travis-ci.org/raubreywhite/org)
[![codecov](https://codecov.io/gh/raubreywhite/org/branch/master/graph/badge.svg)](https://codecov.io/gh/raubreywhite/org)

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

## Solution

My (opinionated) solution is as follows:

Code should be stored in Github. Data should be stored locally in an encrypted volume. Results should be stored on Dropbox, with the results for each day stored in a different folder.

```
# code goes here:
git
  +-- analyses
             +-- 2018
             |      +-- analysis1 <- org::PROJ$HOME
             |      |           +-- Run.R
             |      |           +-- code
             |      |                  +-- CleanData.R
             |      |                  +-- Descriptives.R
             |      |                  +-- Analysis1.R
             |      |                  +-- Graphs1.R
             |      +-- analysis2 <- org::PROJ$HOME
             |                  +-- Run.R
             |                  +-- code
             |                         +-- CleanData.R
             |                         +-- Descriptives.R
             |                         +-- Analysis1.R
             |                         +-- Graphs1.R
             +-- 2019
                    +-- analysis3 <- org::PROJ$HOME
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
             |      +-- analysis1 <- org::PROJ$SHARED
             |      |           +-- 2018-03-12 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-03-15 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-03-18 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             |      |           +-- 2018-06-18 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- table2.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             |      +-- analysis2 <- org::PROJ$SHARED
             |      |           +-- 2018-06-09 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2018-12-15 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           +-- 2019-01-18 <- org::PROJ$SHARED_TODAY
             |      |           |            +-- table1.xlsx
             |      |           |            +-- figure1.png
             |      |           |            +-- figure2.png
             +-- 2019
                    +-- analysis3 <- org::PROJ$SHARED
                    |           +-- 2019-06-09 <- org::PROJ$SHARED_TODAY
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           +-- 2019-12-15 <- org::PROJ$SHARED_TODAY
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           +-- 2020-01-18 <- org::PROJ$SHARED_TODAY
                    |           |            +-- table1.xlsx
                    |           |            +-- figure1.png
                    |           |            +-- figure2.png

# data goes here:
data
  +-- analyses
             +-- 2018
             |      +-- analysis1 <- org::PROJ$RAW
             |      |           +-- data.xlsx
             |      +-- analysis2 <- org::PROJ$RAW
             |      |           +-- data.xlsx
             +-- 2019
                    +-- analysis3 <- org::PROJ$RAW
                                +-- data.xlsx

```

## Code

### org::InitialiseProject

`org::InitialiseProject` takes in 2+ arguments. It then saves its results (i.e. folder locations) in `org::PROJ`, which you will use in all of your subsequent code.

`HOME` is the location of `Run.R` and the `code/` folder. It will be accessible via `org::PROJ$HOME` (but you will rarely need this).

`SHARED` is your results folder. It will create a folder inside `SHARED` with today's date and it will be accessible via `org::PROJ$SHARED_TODAY` (this is where you will store all of your results). Because the folder's name is today's date, this means that it automatically archives one copy of results per day. This allows you and your collaborators to easily check and see how the results have changed over time.

`...` you can specify other folders if you want, and they will also be accessible via `org::PROJ`. Some possible ones are `RAW` (raw data) and `CLEAN` (clean data).

### Run.R 

`Run.R` will be your masterfile. It will sequentially run through every part of your analysis:

- data cleaning
- analysis
- result generation

You will not have any other masterfiles, as this creates confusion when you need to return to your code 2 years later.

All sections of code (e.g. data cleaning, analyses for table 1, analyses for table 2, result generation for table 1, sensitivity analysis 1, etc) will be encapsulated in functions that live in the `code` folder.

An example `Run.R` might look like this:

```
# Gives R permission to create folders on your computer
org::AllowFileManipulationFromInitialiseProject()

# Define the following 'special' locations:
# 'HOME' (i.e. Run.R and code/ folder)
# 'SHARED' (i.e. A folder with today's date will be created here)

# Define any other locations you want:
# 'RAW' (i.e. raw data)
org::InitialiseProject(
  HOME = "/git/analyses/2019/analysis3/",
  SHARED = "/dropbox/analyses_results/2019/analysis3/"
  RAW = "/data/analyses/2019/analysis3/"
)

library(data.table)
library(ggplot2)

# This function would access data located in org::PROJ$RAW
d <- CleanData()

# These functions would save results to org::PROJ$SHARED_TODAY
Table1(d)
Figure1(d)
Figure2(d)
```

### code/

All of your functions should be defined in `org::PROJ$HOME/code`. The function `org::InitialiseProject` automatically sources all of the R scripts in `org::PROJ$HOME/code`, making them available for use.




