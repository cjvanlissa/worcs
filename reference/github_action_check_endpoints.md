# Set up GitHub Actions to Check Endpoints

Sets up a GitHub Action to perform continuous integration (CI) for a
WORCS project. CI automatically evaluates
[`check_endpoints()`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)
or `reproduce(check_endpoints = TRUE)`. at each push or pull request.

## Usage

``` r
github_action_check_endpoints(worcs_directory = ".")

github_action_reproduce(worcs_directory = ".")

github_action_testthat(worcs_directory = ".")
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value "." points to the current directory. Default:
  '.'

## Value

No return value. This function is called for its side effects.

## See also

[`use_github_action`](https://usethis.r-lib.org/reference/use_github_action.html)
[`add_endpoint`](https://cjvanlissa.github.io/worcs/reference/add_endpoint.md)
[`check_endpoints`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md)
