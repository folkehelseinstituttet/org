# org
[![Build Status](https://travis-ci.com/folkehelseinstituttet/org.svg?branch=master)](https://travis-ci.com/folkehelseinstituttet/org)
[![codecov](https://codecov.io/gh/folkehelseinstituttet/org/branch/master/graph/badge.svg)](https://codecov.io/gh/folkehelseinstituttet/org)

A system to help you organize projects. Most analyses have three (or more) main sections: code, results, and data, each with different requirements (version control/sharing/encryption). You provide folder locations and 'org' helps you take care of the details.

Read the introduction vignette [here](http://folkehelseinstituttet.github.io/org/articles/intro.html) or run `help(package="org")`.

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
- [fhidata](https://folkehelseinstituttet.github.io/fhidata)
- [fhiplot](https://folkehelseinstituttet.github.io/fhiplot)
- [fhi](https://folkehelseinstituttet.github.io/fhi)
- [spread](https://folkehelseinstituttet.github.io/spread)
