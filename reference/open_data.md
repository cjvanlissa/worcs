# Use open data in WORCS project

This function saves a data.frame as a `.csv` file (using
[`write.csv`](https://rdrr.io/r/utils/write.table.html)), stores a
checksum in '.worcs', and amends the `.gitignore` file to exclude
`filename`.

## Usage

``` r
open_data(
  data,
  filename = paste0(deparse(substitute(data)), ".csv"),
  codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
  value_labels = paste0("value_labels_", deparse(substitute(data)), ".yml"),
  worcs_directory = ".",
  save_expression = write.csv(x = data, file = filename, row.names = FALSE),
  load_expression = read.csv(file = filename, stringsAsFactors = TRUE),
  ...
)
```

## Arguments

- data:

  A data.frame to save.

- filename:

  Character, naming the file data should be written to. By default,
  constructs a filename from the name of the object passed to `data`.

- codebook:

  Character, naming the file the codebook should be written to. An 'R
  Markdown' codebook will be created and rendered to
  [`github_document`](https://pkgs.rstudio.com/rmarkdown/reference/github_document.html)
  ('markdown' for 'GitHub'). By default, constructs a filename from the
  name of the object passed to `data`, adding the word 'codebook'. Set
  this argument to `NULL` to avoid creating a codebook.

- value_labels:

  Character, naming the file the value labels of factors and ordinal
  variables should be written to. By default, constructs a filename from
  the name of the object passed to `data`, adding the word
  'value_labels'. Set this argument to `NULL` to avoid creating a file
  with value labels.

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value `"."` points to the current directory.

- save_expression:

  An R-expression used to save the `data`. Defaults to
  `write.csv(x = data, file = filename, row.names = FALSE)`, which
  writes a comma-separated, spreadsheet-style file. The arguments `data`
  and `filename` are passed from `open_data()` to the expression defined
  in `save_expression`.

- load_expression:

  An R-expression used to load the `data` from the file created by
  `save_expression`. Defaults to
  `read.csv(file = filename, stringsAsFactors = TRUE)`. This expression
  is stored in the project's `.worcs` file, and invoked by
  [`load_data()`](https://cjvanlissa.github.io/worcs/reference/load_data.md).

- ...:

  Additional arguments passed to and from functions.

## Value

Returns `NULL` invisibly. This function is called for its side effects.

## See also

open_data closed_data save_data

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
  withr::with_tempdir({
    file.create(".worcs")
    df <- iris[1:5, ]
    open_data(df, codebook = NULL)
  })
}
#> ✔ Storing original data in 'df.csv' and updating the checksum in '.worcs'.
#> ✔ Updating '.gitignore'.
#> ✔ Storing value labels in 'value_labels_df.yml'.
```
