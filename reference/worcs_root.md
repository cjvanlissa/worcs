# Return Absolute File Path of WORCS Project Directory

The search starts at `path`, and recursively proceeds up the directory
hierarchy until a `worcs` project directory is found.

## Usage

``` r
worcs_root(path = ".")
```

## Arguments

- path:

  Start directory, Default: '.' (current directory).

## Value

Normalized path of the `worcs` project root directory.

## See also

[`find_root`](https://rprojroot.r-lib.org/reference/find_root.html)

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
withr::with_tempdir({
writeLines("", ".worcs")
worcs_root()
})
}
#> [1] "/tmp/RtmpBe3avx/file20cd399667ff"
```
