# Add Recipe to Generate Endpoints

Add a recipe to a WORCS project file to generate its endpoints.

## Usage

``` r
add_recipe(
  worcs_directory = ".",
  recipe = "rmarkdown::render('manuscript/manuscript.Rmd')",
  terminal = FALSE,
  verbose = TRUE,
  ...
)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value "." points to the current directory. Default:
  '.'

- recipe:

  Character string, indicating the function call to evaluate in order to
  reproduce the endpoints of the WORCS project.

- terminal:

  Logical, indicating whether or not to evaluate the `recipe` in the
  terminal (`TRUE`) or in R (`FALSE`). Defaults to `FALSE`

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: `TRUE`

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
writeLines("test", "test.txt")
add_recipe()
})
}
#> ✔ Adding recipe to '.worcs'.
```
