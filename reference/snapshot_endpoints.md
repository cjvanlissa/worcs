# Snapshot endpoints in WORCS project

Update the checksums of all endpoints in a WORCS project.

## Usage

``` r
snapshot_endpoints(worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value "." points to the current directory. Default:
  '.'

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

- ...:

  Additional arguments.

## Value

No return value. This function is called for its side effects.

## See also

[`add_endpoint`](https://cjvanlissa.github.io/worcs/reference/add_endpoint.md)
[`check_endpoints`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)

## Examples

``` r
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "update_endpoint")
dir.create(test_dir)
setwd(test_dir)
file.create(".worcs")
#> [1] TRUE
writeLines("test", "test.txt")
add_endpoint("test.txt")
writeLines("second test", "test.txt")
snapshot_endpoints()
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
```
