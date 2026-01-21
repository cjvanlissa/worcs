# Specify File Path Relative to WORCS Project Directory

Construct the path to a file inside a `worcs` project directory in a
platform-independent way, see
[file.path](https://rdrr.io/r/base/file.path.html).

## Usage

``` r
worcs_path(..., worcs_directory = ".", fsep = .Platform$file.sep)
```

## Arguments

- ...:

  Character vectors, indicating directory- or file names.

- worcs_directory:

  The project directory (or one of its subdirectories, in which case the
  project directory is determined via
  [worcs_root](https://cjvanlissa.github.io/worcs/reference/worcs_root.md)),
  Default: '.' (current directory).

- fsep:

  Path separator to use.

## Value

Normalized path to file.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
withr::with_tempdir({
writeLines("", ".worcs")
writeLines("hello world", "myfile.txt")
file.exists(worcs_path("myfile.txt"))
})
}
#> [1] TRUE
```
