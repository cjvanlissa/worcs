# worcs 0.1.6

* Workflow vignette updated to address reviewer comments from "Data Science"
* New functions: add_synthetic() and notify_synthetic()
* closed_data() no longer wraps errors from the call to synthetic().
  Thus, the function call fails with an error if data synthesis fails.
* closed_data() now passes formal arguments of synthetic() contained in '...'
  on to synthetic().
* synthetic() now allows 'y' to be referenced in 'predict_expression' when
  'model_expression' is set to NULL, thereby enabling bootstrapping.
* The internal function worcs:::col_message() now renders status messages in
  black print instead of colored print when rmarkdown::render() is on the
  callstack. This avoids errors when knitting to PDF.
  See https://github.com/rstudio/rmarkdown/issues/1951 for the error
  circumvented by this fix.

# worcs 0.1.5

* Necessary update due to breaking changes in dependency from the `gert` package
* Add function add_preregistration() to add a preregistration at a later stage
* Add preregistration templates "PSS" and "Secondary"

# worcs 0.1.4

* Fixed bugs in handling of filenames by open_data() and closed_data()
  codebook.Rmd from the name of the object supplied to the 'data' argument
* By default, open_data() and closed_data() now construct the filenames of the
  .csv and codebook.Rmd from the name of the object supplied to the 'data'
  argument. This also means that the object will be loaded with the same name
  by load_data().
* Add function add_manuscript() to add a manuscript at a later stage
* Major bugfixes in worcs_badge(); this function did not work as intended. Fixed now

# worcs 0.1.3

* Minor bugfixes
* descriptives() now returns mean() instead of sd()
* descriptives() now returns both n and missing
* README.md did now correctly shows .Rproj file
* rticles now declared as import

# worcs 0.1.2

* All documentation updated to ensure compatibility with the submitted version
  of the WORCS-paper.
* Authors and references to WORCS-paper updated to include all co-authors.
* Prevent git_user() from engaging in antisocial behavior, resetting users'
  'Git' credentials, by adding a default argument 'overwrite = !has_git_user()'.
  By default, the function will do nothing when 'Git' user credentials already
  exist.
* Bug fix to load_data() to ensure compatibility with the 'RMarkdown' behavior
  of running code chunks from the .Rmd file directory, instead of from the
  actual working directory.
* Bug fix to cite_all() and cite_essential() to allow escaping literal double @.
* Bug fix to export_project(), which now respects the folder structure within a
  project, and also supports relative paths to ensure portability, even when
  called from a different working than the working directory. Fixing this bug
  required changing the working directory before calling zip(). This change in
  working directory is immediately followed by a call to on.exit(setwd(oldwd)),
  in line with CRAN policy.
* .worcs file is used to determine the existence of a worcs-project recursively.
* .worcs file now tracks entry point for analyses.

# worcs 0.1.1

* First CRAN release.
