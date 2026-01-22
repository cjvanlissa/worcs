# Add endpoint to WORCS project

Add a specific endpoint to the WORCS project file (a filename, or
`"testthat"` integration tests), see Details.

## Usage

``` r
add_endpoint(filename = NULL, worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- filename:

  Character, indicating a file to be tracked as endpoint, or
  `"testthat"` to add a folder of integration tests as endpoints.
  Default: NULL.

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

## Details

Endpoints are either:

1.  Files that are expected to be exactly reproducible (e.g.,
    `"manuscript.html"`, `"myfigure.png"`, `"results_table.csv"`, et
    cetera). For individual files, reproducibility is checked by
    ensuring that the endpoint's checksum is unchanged, see
    [digest](https://eddelbuettel.github.io/digest/man/digest.html). Be
    mindful that the checksum also changes if two files are practically,
    but not literally, identical. This can occur when using random
    numbers anywhere in your analysis (e.g., Monte Carlo estimation, or
    even jittering points in a plot), or when numbers are rounded
    differently in the 15th decimal on different computers.

2.  A folder of integration tests, created using the `testthat` package
    (see
    [add_testthat](https://cjvanlissa.github.io/worcs/reference/add_testthat.md)).
    Note that `testthat` allows you, for example, to test whether
    numbers are equal within rounding tolerance.

## See also

[`snapshot_endpoints`](https://cjvanlissa.github.io/worcs/reference/snapshot_endpoints.md)
[`check_endpoints`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)

## Examples

``` r
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "add_endpoint")
dir.create(test_dir)
setwd(test_dir)
file.create(".worcs")
#> [1] TRUE
writeLines("test", "test.txt")
add_endpoint("test.txt")
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
```
