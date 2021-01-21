# worcs 0.1.7

* Fixed failing tests as requested by dr. Brian Ripley
  + Note that these tests fail because pandoc is outdated on these systems:
    - r-patched-solaris-x86
    - r-release-macos-x86_64
    - r-oldrel-macos-x86_64

## Test environments

* local Windows 10 install, R 4.0.3
* win-builder: R version 4.0.3 (2020-10-10)
* win-builder: R Under development (unstable) (2021-01-18 r79846)
* win-builder: R version 3.6.3 (2020-02-29)
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Ubuntu Linux 16.04 LTS, R-release, GCC
  + Dependency "gert" not available (because openssl is not installed)
* rhub check: Fedora Linux, R-devel, clang, gfortran
  + Dependency "gert" not available (because openssl is not installed)
* Travis linux, release
* Travis linux, oldrel
* Travis linux, devel

## R CMD check results

0 errors | 0 warnings | 0 notes
