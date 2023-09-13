# worcs 0.1.12

* Add functions add_recipe() and reproduce()
* check_worcs_installation() no longer throws error for rticles and prereg
* Add more defensive programming to save_data() and load_data() to prevent errors.
* Further improvement to how checksums are computed; instead of checking how Git
  treats the line endings (which breaks when a project is no longer version
  controlled, e.g., when downloading a ZIP from GitHub), we check if files are
  binary.
* Add github action to reproduce a repo via github actions:
  github_action_reproduce()
* Update Reproduce.Rmd vignette; the advice to download a ZIP from GitHub is bad
  practice, because this ZIP is no longer version controlled with Git.
  
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
