# Add WORCS badge to README.md

Evaluates whether a project meets the criteria of the WORCS checklist
(see
[`worcs_checklist`](https://cjvanlissa.github.io/worcs/reference/worcs_checklist.md)),
and adds a badge to the project's `README.md`.

## Usage

``` r
worcs_badge(
  path = ".",
  update_readme = "README.md",
  update_csv = "checklist.csv"
)
```

## Arguments

- path:

  Character. This can either be the path to a WORCS project folder (a
  project with a `.worcs` file), or the path to a `checklist.csv` file.
  The latter is useful if you want to evaluate a manually updated
  checklist file. Default: '.' (path to current directory).

- update_readme:

  Character. Path to the `README.md` file to add the badge to. Default:
  'README.md'. Set to `NULL` to avoid updating the `README.md` file.

- update_csv:

  Character. Path to the `README.md` file to add the badge to. Default:
  'checklist.csv'. Set to `NULL` to avoid updating the `checklist.csv`
  file.

## Value

No return value. This function is called for its side effects.

## Examples

``` r
example_dir <- file.path(tempdir(), "badge")
dir.create(example_dir)
#> Warning: '/tmp/RtmpzAKLkH/badge' already exists
write("a", file.path(example_dir, ".worcs"))
worcs_badge(path = example_dir,
update_readme = NULL)
```
