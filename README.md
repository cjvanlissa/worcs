
# WORCS <a href='https://osf.io/zcvbs/'><img src='https://github.com/cjvanlissa/worcs/raw/master/docs/worcs_icon.png' align="right" height="139" /></a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CRAN
status](https://www.r-pkg.org/badges/version/worcs)](https://cran.r-project.org/package=worcs)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/grand-total/worcs?color=blue)](https://r-pkg.org/pkg/worcs)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/cjvanlissa/worcs.svg?branch=master)](https://travis-ci.org/cjvanlissa/worcs)
[![CII Best
Practices](https://bestpractices.coreinfrastructure.org/projects/3969/badge)](https://bestpractices.coreinfrastructure.org/projects/3969)
<!--[![Codecov test
coverage](https://codecov.io/gh/cjvanlissa/worcs/branch/master/graph/badge.svg)](https://codecov.io/gh/cjvanlissa/worcs?branch=master)-->
<!--[![DOI](http://joss.theoj.org/papers/10.21105/joss.00978/status.svg)](https://doi.org/10.21105/joss.00978)-->

The Workflow for Open Reproducible Code in Science (WORCS) is an easy to
adopt approach to ensuring a research project meets the requirements of
Open Science from the start. It is based on a “good enough” philosophy,
prioritizing user-friendliness over exhaustiveness. It can be used
either in absence of, or in parallel to, existing requirements for Open
workflows. It can also be enhanced with more elaborate solutions for
specific issues.

## Where do I start?

For most users, the recommended starting point is to [read the preprint
paper](https://osf.io/zcvbs/), which introduces the WORCS workflow,
explains the underlying tools, and illustrates how the `worcs` package
can be used to create a new project that follows the workflow.

The workflow is illustrated below; the [workflow
vignette](https://cjvanlissa.github.io/worcs/articles/workflow.html)
describes each step in detail.

![](https://github.com/cjvanlissa/worcs/raw/master/paper/workflow_graph/workflow.png)<!-- -->

## Installing the package

Before installing the package, please read [this
vignette](https://cjvanlissa.github.io/worcs/articles/setup.html), which
explains how to set up your computer for `worcs`.

After reading [the
vignette](https://cjvanlissa.github.io/worcs/articles/setup.html), you
can install the development version of the `worcs` package from GitHub
with:

``` r
if(!requireNamespace("remotes"))install.packages("remotes")
remotes::install_github("cjvanlissa/worcs", dependencies = TRUE, update = "never")
tinytex::install_tinytex()
worcs::git_user("your_name", "your_email")
```

If you intend to write APA style manuscripts, you can additionally
install the `papaja` package:

``` r
remotes::install_github("crsh/papaja", dependencies = TRUE, update = "never")
```

## Citing WORCS

You can cite WORCS using the following citation (please use the same
citation for either the package, or the paper):

> Van Lissa, C. J., Brandmaier, A. M., Brinkman, L., Lamprecht, A.,
> Peikert, A., , Struiksma, M. E., & Vreede, B. (2020, May 29). WORCS: A
> Workflow for Open Reproducible Code in Science.
> <https://doi.org/10.17605/OSF.IO/ZCVBS>

## About this repository

This repository contains the following:

1.  An R-package called `worcs`, with convenience functions to
    facilitate the WORCS workflow.
2.  In the subfolder `./paper`, the source files for the paper
    describing the WORCS workflow.

The repository serves two functions: To allow users to install the
`worcs` package, and to allow collaborators access to the source code
for the package and paper.

## Repository structure

| File          | Description                     | Usage           |
| :------------ | :------------------------------ | :-------------- |
| \_pkgdown.yml | YAML for package website        | do not edit     |
| DESCRIPTION   | R-package DESCRIPTION           | do not edit     |
| LICENSE.md    | Project license                 | do not edit     |
| NAMESPACE     | R-package namespace             | machine-written |
| README.md     | Read this file to get started\! | do not edit     |
| README.Rmd    | R-markdown source for readme.md | human editable  |
| worcs.Rproj   | RStudio project file            | do not edit     |
| docs/         | Package website                 | machine-written |
| inst/         | RStudio project template files  | human editable  |
| man/          | R-package documentation         | do not edit     |
| paper/        | WORCS paper source files        | human editable  |
| R/            | R-package source code           | human editable  |
| vignettes/    | R-package vignettes             | human editable  |

## Adoption of WORCS by users

As of 2020-11-15, these are indicators of the adoption of `worcs` by
users:

1.  The preprint has been downloaded 582 times, since being published on
    31-05-2020
2.  The `worcs` R-package has been downloaded 2575 times from CRAN,
    since being published on 18-05-2020
3.  The GitHub project has been forked 8 times, watched 5 times, and
    starred 40 times
4.  The lead author has given invited lectures on WORCS at:
      - Max-Planck-Institute for Human Development (2020)  
      - Open Science Community Rotterdam (2020)  
      - Eindhoven University of Technology (2020)  
5.  WORCS is currently used in the following GitHub repositories (sorted
    by user):
      - cjvanlissa
          - [veni\_sysrev](https://github.com/cjvanlissa/veni_sysrev)  
          - [IHBT-SEM](https://github.com/cjvanlissa/IHBT-SEM)  
          - [schumpe](https://github.com/cjvanlissa/schumpe)  
          - [storm\_meta\_father\_mother](https://github.com/cjvanlissa/storm_meta_father_mother)  
          - [placebo\_adhd](https://github.com/cjvanlissa/placebo_adhd)  
          - [mpib](https://github.com/cjvanlissa/mpib)  
          - [coping\_covid](https://github.com/cjvanlissa/coping_covid)  
      - IndrajeetPatil
          - [worcs\_practice](https://github.com/IndrajeetPatil/worcs_practice)  
      - EstherPlomp
          - [RDM-survey](https://github.com/EstherPlomp/RDM-survey)  
      - lisallreiber
          - [worcs\_ws\_empty](https://github.com/lisallreiber/worcs_ws_empty)  
      - KimBaldry
          - [BIO-MATE](https://github.com/KimBaldry/BIO-MATE)

## Contributing and Contact Information

We are always eager to receive user feedback and contributions to help
us improve both the workflow and the software. Major contributions
warrant coauthorship to the package. Please contact the lead author at
<c.j.vanlissa@uu.nl>, or:

  - [File a GitHub issue](https://github.com/cjvanlissa/worcs) for
    feedback, bug reports or feature requests
  - [Make a pull request](https://github.com/cjvanlissa/worcs/pulls) to
    contribute your code or prose

By participating in this project, you agree to abide by the [Contributor
Code of Conduct v2.0](https://www.contributor-covenant.org/).
Contributions to the package must adhere to the [tidyverse style
guide](https://style.tidyverse.org/). When contributing code, please add
tests for that contribution to the `tests/testthat` folder, and ensure
that these tests pass on
[Travis-CI](https://travis-ci.org/github/cjvanlissa/worcs).

## Acknowledgements

The worcs logo is inspired by the Open Science Badges by the Center for
Open Science (CC-BY-4.0), and makes use of the gear, services, gears,
preferences, settings icon, made by MD Badsha Meah from www.freeicons.io
(CC-BY-3.0).
