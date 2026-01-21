# Add License File to Project

This function wraps `usethis`' `licenses` functions, which are designed
for R-packages. This function makes them applicable to other use cases
(e.g., WORCS projects, FAIR theory).

## Usage

``` r
add_license_file(path = ".", license = "ccby", ...)
```

## Arguments

- path:

  Character, indicating the directory in which to create the license
  file. Default: '.'.

- license:

  Character, indicating which license function to call. The `usethis`
  functions all have the form `use_{licensename}_license()`. The
  `license` argument consists only of the `{licensename}`, e.g. `ccby`.

- ...:

  Additional arguments passed to `usethis` function.

## Value

No return value. This function is called for its side effects.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
withr::with_tempdir({
add_license_file(path = ".",
                 license = "proprietary",
                 copyright_holder = "test")
})
}
```
