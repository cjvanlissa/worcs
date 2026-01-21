# Set global 'Git' credentials

This function is a wrapper for
[`git_config_global_set`](https://docs.ropensci.org/gert/reference/git_config.html).
It sets two name/value pairs at once: `name = "user.name"` is set to the
value of the `name` argument, and `name = "user.email"` is set to the
value of the `email` argument.

## Usage

``` r
git_user(name, email, overwrite = !has_git_user(), verbose = TRUE)
```

## Arguments

- name:

  Character. The user name you want to use with 'Git'.

- email:

  Character. The email address you want to use with 'Git'.

- overwrite:

  Logical. Whether or not to overwrite existing 'Git' credentials. Use
  this to prevent code from accidentally overwriting existing 'Git'
  credentials. The default value uses
  [`has_git_user`](https://cjvanlissa.github.io/worcs/reference/has_git_user.md)
  to set overwrite to `FALSE` if user credentials already exist, and to
  `TRUE` if no user credentials exist.

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

## Value

No return value. This function is called for its side effects.

## Examples

``` r
git_user("name", "email", overwrite = FALSE)
```
