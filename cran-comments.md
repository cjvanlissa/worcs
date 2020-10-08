# worcs 0.1.5

Apologies for the release of yet another version, but I was notified that our
dependency `gert` has implemented some breaking changes. To ensure compatibility
with `gert`, I hereby offer an update.

* Necessary update due to breaking changes in dependency from the `gert` package
* Add function add_preregistration() to add a preregistration at a later stage
* Add preregistration templates "PSS" and "Secondary"

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
