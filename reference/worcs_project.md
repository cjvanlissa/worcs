# Create new WORCS project

Creates a new 'worcs' project. This function is invoked by the 'RStudio'
project template manager, but can also be called directly to create a
WORCS project through syntax or the console.

## Usage

``` r
worcs_project(
  path = "worcs_project",
  manuscript = "APA6",
  preregistration = "cos_prereg",
  add_license = "ccby",
  use_renv = TRUE,
  use_targets = FALSE,
  remote_repo = "https",
  verbose = TRUE,
  ...
)
```

## Arguments

- path:

  Character, indicating the directory in which to create the 'worcs'
  project. Default: 'worcs_project'.

- manuscript:

  Character, indicating what template to use for the 'R Markdown'
  manuscript. Default: 'APA6'. Available choices include `APA6` from the
  `papaja` package, a
  [`github_document`](https://pkgs.rstudio.com/rmarkdown/reference/github_document.html),
  and templates included in the
  [`rticles`](https://pkgs.rstudio.com/rticles/reference/rticles-package.html)
  package. For more information, see
  [`add_manuscript`](https://cjvanlissa.github.io/worcs/reference/add_manuscript.md).

- preregistration:

  Character, indicating what template to use for the preregistration.
  Default: 'cos_prereg'. Available choices include:
  `"PSS", "Secondary", "None"`, and all templates from the
  [`prereg`](https://rdrr.io/pkg/prereg/man/prereg.html) package. For
  more information, see
  [`add_preregistration`](https://cjvanlissa.github.io/worcs/reference/add_preregistration.md).

- add_license:

  Character, indicating what license to include. Default: 'ccby'.
  Available options include:
  `c("cc0", "ccby", "gpl", "gpl3", "agpl", "agpl3", "apache", "apl2", "lgpl", "mit", "proprietary", "None"`.
  For more information, see
  [`use_cc0_license`](https://usethis.r-lib.org/reference/licenses.html).

- use_renv:

  Logical, indicating whether or not to use 'renv' to make the project
  reproducible. Default: TRUE. See
  [`init`](https://rstudio.github.io/renv/reference/init.html).

- use_targets:

  Logical, indicating whether or not to use 'targets' to create a
  Make-like pipeline. Default: FALSE See
  [`targets-package`](https://docs.ropensci.org/targets/reference/targets-package.html).

- remote_repo:

  Character, URL of, or name for, the remote repository for this
  project. If a URL of an existing repository is specified, it should
  have the form `https://github.com[username][repo].git` (preferred) or
  `git@[...].git` (if using SSH). Alternatively, a name for a new
  repository can be provided. If a 'GitHub' user is authenticated on
  your device, this repository will be created on your account. Finally,
  a commit will be made containing the 'README.md' file, and will be
  pushed to the remote repository. Default: 'https', which results in no
  repository being created.

- verbose:

  Logical. Whether or not to print messages to the console during
  project creation. Default: TRUE

- ...:

  Additional arguments passed to and from functions.

## Value

No return value. This function is called for its side effects.

## Examples

``` r
the_test <- "worcs_template"
old_wd <- getwd()
dir.create(file.path(tempdir(), the_test))
do.call(git_user, worcs:::get_user())
worcs_project(file.path(tempdir(), the_test, "worcs_project"),
              manuscript = "github_document",
              preregistration = "None",
              add_license = "None",
              use_renv = FALSE,
              remote_repo = "https")
#> ✔ Creating manuscript files.
#> ✔ Adding recipe to '.worcs'.
#> ✔ Creating first commit (committing README.md).
setwd(old_wd)
unlink(file.path(tempdir(), the_test))
```
