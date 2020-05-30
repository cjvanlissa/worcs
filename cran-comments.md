# Version 0.1.2

Addresses comment by Uwe Ligges:

* Found the following (possibly) invalid URLs:
  URL: https://bookdown.org/yihui/RMarkdown-cookbook/bibliography.html
    + Status: Solved
    + Reason: Capitalization of RMarkdown caused this URL to fail. This works:
    https://bookdown.org/yihui/rmarkdown-cookbook/bibliography.html

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
