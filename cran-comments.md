# worcs 0.1.6

* Workflow vignette updated to address reviewer comments from "Data Science"
* New functions: add_synthetic() and notify_synthetic()
* closed_data() no longer wraps errors from the call to synthetic().
  Thus, the function call fails with an error if data synthetis fails.
* closed_data() now passes formal arguments of synthetic() contained in '...'
  on to synthetic().
* synthetic() now allows 'y' to be referenced in 'predict_expression' when
  'model_expression' is set to NULL, thereby enabling bootstrapping.
* The internal function worcs:::col_message() now renders status messages in
  black print instead of colored print when rmarkdown::render() is on the
  callstack. This avoids errors when knitting to PDF.
  See https://github.com/rstudio/rmarkdown/issues/1951 for the error
  circumvented by this fix.

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
