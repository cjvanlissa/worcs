
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!--[![CRAN status](https://www.r-pkg.org/badges/version/tidySEM)](https://cran.r-project.org/package=tidySEM)
[![](https://cranlogs.r-pkg.org/badges/tidySEM)](https://cran.r-project.org/package=tidySEM)-->

<!--[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/cjvanlissa/tidySEM.svg?branch=master)](https://travis-ci.org/cjvanlissa/tidySEM)
[![Codecov test
coverage](https://codecov.io/gh/cjvanlissa/tidySEM/branch/master/graph/badge.svg)](https://codecov.io/gh/cjvanlissa/tidySEM?branch=master)
<!--[![DOI](http://joss.theoj.org/papers/10.21105/joss.00978/status.svg)](https://doi.org/10.21105/joss.00978)-->

# WORCS

The Workflow for Open Reproducible Code in Science (WORCS) is an easy to
adopt approach to ensuring a research project meets the requirements of
Open Science from the start. It is based on a “good enough” philosophy,
opting for user-friendliness instead of thoroughness. It can be used
either in absence of, or in parallel to, existing requirements for Open
workflows. It can also be enhanced with more elaborate solutions for
specific issues.

## Where do I start?

For most users, the recommended starting point is to read [the preprint
paper, available on the Open Science Framework](https://osf.io/zcvbs/).

The paper describes the WORCS workflow, and how the `worcs` package fits
into that workflow.

## About this repository

This repository contains the following:

1.  An R-package called `worcs`, with convenience functions to
    facilitate the WORCS workflow.
2.  In the subfolder `./paper`, the source files for the paper
    describing the WORCS workflow.

The repository serves two functions: To allow users to install the
`worcs` package, and to allow collaborators access to the source code
for the package and paper.

## Installing the package

Before installing the package, please read [this
vignette](https://cjvanlissa.github.io/worcs/articles/setup.html), which
explains how to set up your computer for `worcs`.

After reading [the
vignette](https://cjvanlissa.github.io/worcs/articles/setup.html), you
can install the development version of the `worcs` package from GitHub
with:

``` r
install.packages("devtools")
devtools::install_github("cjvanlissa/tidySEM")
```

## Citing WORCS

You can cite WORCS using the following citation (please use the same
citation for either the package, or the paper):

> Van Lissa, C. J. (2020, February 11). WORCS: A Workflow for Open
> Reproducible Code in Science. <https://doi.org/10.17605/OSF.IO/ZCVBS>

## Contributing and Contact Information

WORCS is actively recruiting collaborators with valuable expertise, to
improve both the workflow and the package. Relevant contributions
warrant coauthorship to the paper. Please contact the lead author at
<c.j.vanlissa@uu.nl>, or:

  - File a GitHub issue [here](https://github.com/cjvanlissa/tidySEM)
  - Make a pull request
    [here](https://github.com/cjvanlissa/tidySEM/pulls)

By participating in this project, you agree to abide by the [Contributor
Code of Conduct v2.0](https://www.contributor-covenant.org/).
