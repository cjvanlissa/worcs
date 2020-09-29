# worcs 0.1.4

* Fixed bugs in handling of filenames by open_data() and closed_data()
  codebook.Rmd from the name of the object supplied to the 'data' argument
* By default, open_data() and closed_data() now construct the filenames of the
  .csv and codebook.Rmd from the name of the object supplied to the 'data'
  argument. This also means that the object will be loaded with the same name
  by load_data().
* Add function add_manuscript() to add a manuscript at a later stage
* Major bugfixes in worcs_badge(); this function did not work as intended. Fixed now

## Test environments

* local Windows 10 install, R 4.0.2
* win-builder: release, R 4.0.2 (2020-06-22)
* win-builder: oldrelease: R version 3.6.3 (2020-02-29)
* win-builder: devel: R Under development (unstable) (2020-09-28 r79268)
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Fedora Linux, R-devel, clang, gfortran
* rhub check: Ubuntu Linux 16.04 LTS, R-release, GCC
  + Preperror: Dependency 'openssl' not available
* Travis linux, release
* Travis linux, oldrel
* Travis linux, devel

## R CMD check results

0 errors | 0 warnings | 0 notes
