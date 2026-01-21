# Check whether global 'Git' credentials exist

Check whether the values `user.name` and `user.email` exist exist for
the current repository. Uses
[`git_signature_default`](https://docs.ropensci.org/gert/reference/git_signature.html).

## Usage

``` r
has_git_user(repo = ".")
```

## Arguments

- repo:

  The path to the git repository.

## Value

Logical, indicating whether 'Git' global configuration settings could be
retrieved, and contained the values `user.name` and `user.email`.

## Examples

``` r
testdir <- file.path(tempdir(), "test_git_user")
dir.create(testdir)
gert::git_init(testdir)
has_git_user(testdir)
unlink(testdir, recursive = TRUE)
```
