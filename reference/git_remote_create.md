# Create a New 'GitHub' Repository

Given that a 'GitHub' user is configured, with the appropriate
permissions, this function creates a new repository on your account.

## Usage

``` r
git_remote_create(name, private = TRUE)
```

## Arguments

- name:

  Name of the repository to be created.

- private:

  Whether or not the repository should be private, defaults to `FALSE`.

## Value

Invisibly returns a logical value, indicating whether the function was
successful or not.

## Examples

``` r
if (FALSE) { # \dontrun{
git_remote_create()
} # }
```
