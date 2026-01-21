# Publish a Release on 'GitHub'

Given that a 'GitHub' user is configured, with the appropriate
permissions, this function pushes the current branch (if safe), then
publishes a 'GitHub' Release of the repository indicated by `repo` to
that user's account.

## Usage

``` r
git_release_publish(repo = ".", tag_name = NULL, release_name = NULL)
```

## Arguments

- repo:

  The path to the 'Git' repository.

- tag_name:

  Optional character string to specify the tag name. By default, this is
  set to `NULL` and `git_release_publish()` uses version numbers
  starting with `0.1.0` for both the `tag_name` and `release_name`
  arguments. Override this behavior, for example, to increment the major
  version number by specifying `0.2.0`.

- release_name:

  Optional character string to specify the tag name. By default, this is
  set to `NULL` and `git_release_publish()` uses version numbers
  starting with `0.1.0` for both the `tag_name` and `release_name`
  arguments. Override this behavior, for example, to increment the major
  version number by specifying `0.2.0`.

## Value

No return value. This function is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
git_release_publish()
} # }
```
