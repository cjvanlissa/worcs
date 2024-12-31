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
* win-builder: R version 4.4.2 (2024-10-31 ucrt)
* win-builder: R Under development (unstable) (2024-12-30 r87496 ucrt)
* win-builder: R version 4.3.3 (2024-02-29 ucrt)
* Rhub: linux (R-devel)
* Rhub: macos (R-devel)
* Rhub: macos-arm64 (R-devel)
* Rhub: windows (R-devel)
* GitHub Actions: macos-latest (release)
* GitHub Actions: windows-latest (release)
* GitHub Actions: ubuntu-latest (devel)
* GitHub Actions: ubuntu-latest (release)
* GitHub Actions: ubuntu-latest (oldrel-1)

## R CMD check results

0 errors | 0 warnings | 0 notes
