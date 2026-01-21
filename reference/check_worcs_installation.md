# Check worcs dependencies

This function checks that all worcs dependencies are correctly
installed, and suggests how to remedy any missing dependencies.

## Usage

``` r
check_worcs_installation(what = "all")

check_dependencies(package = "worcs")

check_git()

check_github(pat = TRUE, ssh = FALSE)

check_ssh()

check_tinytex()

check_rmarkdown()

check_renv()
```

## Arguments

- what:

  Character vector indicating which dependencies to check. Default:
  `"all"`. All checks defined in the Usage section can be called, e.g.
  `check_git` can be called using the argument `what = "git"`.

- package:

  Atomic character vector, indicating for which package to check the
  dependencies.

- pat:

  Logical, whether to run tests for the existence and functioning of a
  GitHub Personal Access Token (PAT). This is the preferred method of
  authentication, so defaults to TRUE.

- ssh:

  Logical, whether to run tests for the existence and functioning of an
  SSH key. This method of authentication is not recommended, so defaults
  to FALSE.

## Value

Logical, indicating whether all checks passed or not.

## Examples

``` r
check_worcs_installation("none")
```
