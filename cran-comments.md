# Version 0.1.2

* All documentation updated to ensure compatibility with the submitted version
  of the WORCS-paper.
* Authors and references to WORCS-paper updated to include all co-authors.
* Bug fix to load_data() to ensure compatibility with the 'RMarkdown' behavior
  of running code chunks from the .Rmd file directory, instead of from the
  actual working directory.
* Bug fix to cite_all() and cite_essential() to allow escaping literal double @.
* Bug fix to export_project(), which now respects the folder structure within a
  project, and also supports relative paths to ensure portability, even when
  called from a different working than the working directory. Fixing this bug
  required changing the working directory before calling zip(). This change in
  working directory is immediately followed by a call to on.exit(setwd(oldwd)),
  in line with CRAN policy.
* .worcs file is used to determine the existence of a worcs-project recursively.
* .worcs file now tracks entry point for analyses.

## Test environments

* local Windows 10 install, R 4.0.0
* local linux-gnu Solus 4.1 Fortitude, R version 3.6.3 (2020-02-29)
* win-builder: release, R 4.0.0 2020-04-24 07:05:34 Arbor Day 
* win-builder: oldrelease: R version 3.6.3 (2020-02-29)
* win-builder: devel: R Under development (unstable) (2020-05-26 r78577)
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Fedora Linux, R-devel, clang, gfortran
* Travis linux, release
* Travis linux, oldrel
* Travis linux, devel

## R CMD check results

0 errors | 0 warnings | 1 note

NOTE: Possibly mis-spelled words in DESCRIPTION:
  Lamprecht (34:41)
  Struiksma (34:52)

Response: These are co-author names.
