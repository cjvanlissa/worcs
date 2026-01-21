# Add endpoint to WORCS project

Add a specific endpoint to the WORCS project file. Endpoints are files
that are expected to be exactly reproducible (e.g., a manuscript,
figure, table, et cetera). Reproducibility is checked by ensuring the
endpoint's checksum is unchanged.

## Usage

``` r
add_endpoint(filename = NULL, worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- filename:

  Character, indicating the file to be tracked as endpoint. Default:
  NULL.

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
