# Reproduce WORCS Project

Evaluate the recipe contained in a WORCS project to derive its
endpoints.

## Usage

``` r
reproduce(worcs_directory = ".", verbose = TRUE, check_endpoints = TRUE, ...)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value "." points to the current directory. Default:
  '.'

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: `TRUE`

- check_endpoints:

  Logical. Whether or not to call
  [`check_endpoints()`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)
  after reproducing the recipe. Default: `TRUE`

- ...:

  Additional arguments.

## Value

No return value. This function is called for its side effects.

## See also

[`add_endpoint`](https://cjvanlissa.github.io/worcs/reference/add_endpoint.md)
[`snapshot_endpoints`](https://cjvanlissa.github.io/worcs/reference/snapshot_endpoints.md)
[`check_endpoints`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)

## Examples

``` r
# Create directory to run the example
if(requireNamespace("withr", quietly = TRUE)){
withr::with_tempdir({
file.create(".worcs")
worcs:::add_recipe(recipe = 'writeLines("test", "test.txt")')
})
}
#> ✔ Adding recipe to '.worcs'.
```
