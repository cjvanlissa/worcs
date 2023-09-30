# worcs 0.1.13

* Address Prof. Brian Ripley's comment: "Packages in Suggests should be used
  conditionally: see 'Writing R Extensions'. This needs to be corrected even if
  the missing package(s) become available. It can be tested by checking with
  _R_CHECK_DEPENDS_ONLY_=true."

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
