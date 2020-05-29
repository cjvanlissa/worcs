# worcs 0.1.2

* All documentation updated to ensure compatibility with the submitted version
  of the WORCS-paper.
* Authors and references to WORCS-paper updated to include all co-authors.
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
