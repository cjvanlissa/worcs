# Modify .gitignore file

Arguments passed through `...` are added to the .gitignore file.
Elements already present in the file are modified. When `ignore = TRUE`,
the arguments are added to the .gitignore file, which will cause 'Git'
to not track them.

When `ignore = FALSE`, the arguments are prepended with `!`, This works
as a "double negation", and will cause 'Git' to track the files.

## Usage

``` r
git_ignore(..., ignore = TRUE, repo = ".")
```

## Arguments

- ...:

  Any number of character arguments, representing files to be added to
  the .gitignore file.

- ignore:

  Logical. Whether or not 'Git' should ignore these files.

- repo:

  a path to an existing repository, or a git_repository object as
  returned by git_open, git_init or git_clone.

## Value

No return value. This function is called for its side effects.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
withr::with_tempdir({
dir.create(".git")
git_ignore("ignorethis.file")
})
}
```
