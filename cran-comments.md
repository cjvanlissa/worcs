# Version 0.1.1

This version addresses the comments by CRAN team member Martina Schmirl:
* Write package, software, and API names in single quotes in title and 
  description.
  - We have done as requested; changed names include 'R', 'RStudio', 'Git',
    'GitHub', and 'Rmarkdown'
* Add references in the description field of your DESCRIPTION file in the form
  authors (year) <doi:...>
  - We have added this reference to DESCRIPTION:
    Van Lissa, Brandmaier, Brinkman, & Vreede (2020) <doi:10.17605/OSF.IO/ZCVBS>
* Please add \value to .Rd files regarding exported methods and explain the
  functions results in the documentation.
  - We have done as requested.

## Test environments

* local Windows 10 install, R 3.6.2
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Ubuntu Linux 16.04 LTS, R-release, GCC
  + PREPERROR: Dependency 'openssl' is not available. Bug reported on R-hub GitHub page https://github.com/r-hub/sysreqsdb/issues/77
* rhub check: Fedora Linux, R-devel, clang, gfortran
* win-builder: release, R 4.0.0 2020-04-24 07:05:34 Arbor Day 
* win-builder: oldrelease: R 3.6.3 2020-02-29 08:05:16 Holding the Windsock

## R CMD check results

0 errors | 0 warnings | 1 notes

NOTE: New submission
