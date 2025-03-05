# worcs 0.1.18

* Clean up examples in function documentation

# worcs 0.1.17

* Addresses issues raised by Prof. Brian Ripley:
    + https://www.stats.ox.ac.uk/pub/bdr/noSuggests/worcs.out
* Make tests that require pandoc conditional
* Update package startup message

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

# worcs 0.1.15

* Add integration with the `targets` package
* Stricter enforcement of ".Rmd" case in filenames to avoid Linux errors

# worcs 0.1.14

* Fix checksum when it is calculated indirectly (e.g., in Rmarkdown code chunk)
* Fix error on r-release-linux-x86_64
* Fix documentation; replace \itemize tags with \describe tags
* Improve handling of relative file paths in `worcs:::save_data()`

# worcs 0.1.13

* Address Prof. Brian Ripley's comment: "Packages in Suggests should be used
  conditionally: see 'Writing R Extensions'. This needs to be corrected even if
  the missing package(s) become available. It can be tested by checking with
  `_R_CHECK_DEPENDS_ONLY_=true`.

# worcs 0.1.12

* Add functions `add_recipe()` and `reproduce()`
* `check_worcs_installation()` no longer throws error for rticles and prereg
* Add more defensive programming to `save_data()` and `load_data()` to prevent errors.
* Further improvement to how checksums are computed; instead of checking how Git
  treats the line endings (which breaks when a project is no longer version
  controlled, e.g., when downloading a ZIP from GitHub), we check if files are
  binary.
* Add github action to reproduce a repo via github actions:
  `github_action_reproduce()`
* Update `vignette("Reproduce")`; the advice to download a ZIP from GitHub is bad
  practice, because this ZIP is no longer version controlled with Git.
  
# worcs 0.1.11

* Checksums are computed differently from preceding versions,
  to account for the fact that Git changes end of line characters which breaks
  consistency of checksums across operating systems.
* Add endpoint functionality: `add_endpoint()`, `snapshot_endpoints()`, and
  `check_endpoints()`
* Add github action for endpoints: `github_action_check_endpoints()`
* Improve handling of relative filenames in `save_data()`
* fix bug related to file path of codebook and metadata
* add function `report()`

# worcs 0.1.10

* Fix breaking bug in `check_worcs_installation()` introduced in version 0.1.9
* Update setup vignette to reflect new GitHub authentication protocols

# worcs 0.1.9

* `closed_data()` and `open_data()` now store factor and ordered value labels in a
  YAML file
* Added functions `data_unlabel()` and `data_label()`, which respectively coerce
  factors to integer, and restore integers to factors using metadata stored in
  a YAML file
* `load_data()` attempts to coerce variable classes using the codebook, and
  restores ordered levels from the value_labels YAML file 
* Update templates from rticles and prereg packages
* Add `check_worcs_installation()` function to determine whether all non-R-package
  dependencies are installed correctly
* Update references to WORCS paper
* Replace GitHub version of papaja with CRAN version
* Fix URLs
* Update rticles and prereg templates
* Handle literal function names from rticles and prereg, such that users can use
  all available options from those packages without worcs explicitly referencing
  those functions
* Add arguments 'save_expression' and 'load_expression' to `closed_data()` and
  `open_data()`. This allows users to save data in different formats. 
  The 'load_expression' is stored in the .worcs file, and referenced by
  `load_data()`.

# worcs 0.1.8

* Declared pandoc in SystemRequirements
* Made all examples using pandoc conditional on availability of pandoc
* Functions that wrap `rmarkdown::render()` now return NULL when pandoc is not
  available

# worcs 0.1.7

* Fixed failing tests as requested by dr. Brian Ripley

# worcs 0.1.6

* Workflow vignette updated to address reviewer comments from "Data Science"
* New functions: `add_synthetic()` and `notify_synthetic()`
* `closed_data()` no longer wraps errors from the call to synthetic().
  Thus, the function call fails with an error if data synthesis fails.
* `closed_data()` now passes formal arguments of synthetic() contained in '...'
  on to `synthetic()`.
* `synthetic()` now allows 'y' to be referenced in 'predict_expression' when
  'model_expression' is set to NULL, thereby enabling bootstrapping.
* The internal function `worcs:::col_message()` now renders status messages in
  black print instead of colored print when `rmarkdown::render()` is on the
  callstack. This avoids errors when knitting to PDF.
  See https://github.com/rstudio/rmarkdown/issues/1951 for the error
  circumvented by this fix.

# worcs 0.1.5

* Necessary update due to breaking changes in dependency from the `gert` package
* Add function `add_preregistration()` to add a preregistration at a later stage
* Add preregistration templates "PSS" and "Secondary"

# worcs 0.1.4

* Fixed bugs in handling of filenames by `open_data()` and `closed_data()`
  codebook.Rmd from the name of the object supplied to the 'data' argument
* By default, `open_data()` and `closed_data()` now construct the filenames of the
  .csv and codebook.Rmd from the name of the object supplied to the 'data'
  argument. This also means that the object will be loaded with the same name
  by `load_data()`.
* Add function `add_manuscript()` to add a manuscript at a later stage
* Major bugfixes in `worcs_badge()`; this function did not work as intended. Fixed now

# worcs 0.1.3

* Minor bugfixes
* `descriptives()` now returns `mean()` instead of `sd()`
* `descriptives()` now returns both n and missing
* README.md did now correctly shows .Rproj file
* rticles now declared as import

# worcs 0.1.2

* All documentation updated to ensure compatibility with the submitted version
  of the WORCS-paper.
* Authors and references to WORCS-paper updated to include all co-authors.
* Prevent `git_user()` from engaging in antisocial behavior, resetting users'
  'Git' credentials, by adding a default argument 'overwrite = !has_git_user()'.
  By default, the function will do nothing when 'Git' user credentials already
  exist.
* Bug fix to `load_data()` to ensure compatibility with the 'RMarkdown' behavior
  of running code chunks from the .Rmd file directory, instead of from the
  actual working directory.
* Bug fix to `cite_all()` and `cite_essential()` to allow escaping literal double @.
* Bug fix to `export_project()`, which now respects the folder structure within a
  project, and also supports relative paths to ensure portability, even when
  called from a different working than the working directory. Fixing this bug
  required changing the working directory before calling `zip()`. This change in
  working directory is immediately followed by a call to `on.exit(setwd(oldwd))`,
  in line with CRAN policy.
* .worcs file is used to determine the existence of a worcs-project recursively.
* .worcs file now tracks entry point for analyses.

# worcs 0.1.1

* First CRAN release.
