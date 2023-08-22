# worcs 0.1.11

* Checksums are computed differently from preceding versions,
  to account for the fact that Git changes end of line characters which breaks
  consistency of checksums across operating systems.
* Add endpoint functionality: add_endpoint(), snapshot_endpoints(), and
  check_endpoints()
* Add github action for endpoints: github_action_check_endpoints()
* Improve handling of relative filenames in save_data()
* fix bug related to file path of codebook and metadata
* add function report()
  
## Test environments

* local Windows 11 install, R 4.2.1
* win-builder: release
* win-builder: development
* win-builder: oldversion
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Ubuntu Linux 16.04 LTS, R-release, GCC
* rhub check: Fedora Linux, R-devel, clang, gfortran

## R CMD check results

0 errors | 0 warnings | 0 notes
