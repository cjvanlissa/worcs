# Add targets to WORCS Project

Add a computational pipeline to a `worcs` project using the `targets`
and `tarchetypes` packages (which must be installed). See those packages
for extensive documentation.

## Usage

``` r
add_targets(worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value "." points to the current directory. Default:
  '.'

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: `TRUE`

- ...:

  Arguments passed to
  [`targets::use_targets()`](https://docs.ropensci.org/targets/reference/use_targets.html).

## Value

No return value. This function is called for its side effects.

## Examples

``` r
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "targets")
dir.create(test_dir)
setwd(test_dir)
file.create(".worcs")
#> [1] TRUE
add_targets()
#> ✔ Wrote _targets.R
#> ✔ Added targets to project.
#> ✔ Setting recipe to targets::tar_make().
#> ✔ Creating directory './R/' for targets scripts.
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
```
