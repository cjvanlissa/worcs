# worcs 0.1.16

* Add git_remote_create(), git_release_publish()
* Add add_license_file()
* Make usethis 3.0.0 required because use_github_action() did not have argument
  'badge' in earlier versions
* github_actions functions now check if 'badge' argument exists
* github_actions functions try to modify readme.md
* Added checks to see if original data are available to reproduce() and
  github_actions_reproduce(), because it is likely that analyses should fail to
  reproduce if original data are not available
* Set default priority to 1 and tarchetypes::tar_render() priority to 0 so that
  all analyses are completed before the manuscript is rendered
* Small bugfix in git_update() allows it to push another repository than the
  active one
* User interface now makes use of the cli package

## Test environments

* local Windows 11, R 4.3.2
* local Ubuntu 22 x86_64-pc-linux-gnu, R 4.4.1
* win-builder: R Under development (unstable) (2024-09-13 r87147 ucrt)
* win-builder: R version 4.4.1 (2024-06-14 ucrt)
* win-builder: R version 4.3.3 (2024-02-29 ucrt)
* Rhub  [VM] windows        R-* (any version)                     windows-latest on GitHub
* Rhub  [CT] atlas          R-devel (2024-09-13 r87147)           Fedora Linux 38 (Container Image)
* Rhub  [CT] c23            R-devel (2024-09-12 r87143)           Ubuntu 22.04.4 LTS
* GitHub Actions, os: macos-latest,   r: 'release'
* GitHub Actions, os: windows-latest, r: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'release'
* GitHub Actions, os: ubuntu-latest,   r: 'oldrel-1'

## R CMD check results

0 errors | 0 warnings | 0 notes
