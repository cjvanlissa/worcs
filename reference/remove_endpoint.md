# Remove endpoint from WORCS project

Remove an endpoint from a WORCS project.

## Usage

``` r
remove_endpoint(filename = NULL, worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- filename:

  Character, indicating the file to be removed from the endpoints.
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

None, prints to the console.

## See also

[`add_endpoint`](https://cjvanlissa.github.io/worcs/reference/add_endpoint.md)
[`snapshot_endpoints`](https://cjvanlissa.github.io/worcs/reference/snapshot_endpoints.md)

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
 withr::with_tempdir({
   file.create(".worcs")
   write.csv(iris, "iris.csv")
   add_endpoint("iris.csv")
   list_endpoints()
   remove_endpoint("iris.csv")
   list_endpoints()
 })
}
```
