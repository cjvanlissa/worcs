# worcs 0.1.15

* Add integration with the `targets` package
* Stricter enforcement of ".Rmd" case in filenames to avoid Linux errors

## Test environments

* local Windows 11, R 4.3.2
* local Ubuntu 22 x86_64-pc-linux-gnu, R 4.4.1
* win-builder: release
* win-builder: development
* win-builder: oldversion
* rhub check: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* rhub check: Ubuntu Linux 16.04 LTS, R-release, GCC
* rhub check: Fedora Linux, R-devel, clang, gfortran
* GitHub Actions, os: macos-latest,   r: 'release'
* GitHub Actions, os: windows-latest, r: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'oldrel-1'

## R CMD check results

0 errors | 0 warnings | 0 notes
