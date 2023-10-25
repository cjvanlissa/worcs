# worcs 0.1.14

* Fix checksum when it is calculated indirectly (e.g., in Rmarkdown code chunk)
* Fix error on r-release-linux-x86_64
* Fix documentation; replace \itemize tags with \describe tags
* Improve handling of relative file paths in worcs:::save_data()

## Test environments

* local Windows 11 install, R 4.3.0
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
