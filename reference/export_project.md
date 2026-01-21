# Export project to .zip file

Export project to .zip file

## Usage

``` r
export_project(zipfile = NULL, worcs_directory = ".", open_data = TRUE)
```

## Arguments

- zipfile:

  Character. Path to a `.zip` file that is to be created. The default
  argument `NULL` creates a `.zip` file in the directory one level above
  the 'worcs' project directory. By default, all files tracked by 'Git'
  are included in the `.zip` file, excluding 'data.csv' if
  `open_data = FALSE`.

- worcs_directory:

  Character. Path to the WORCS project directory to export. Defaults to
  `"."`, which refers to the current working directory.

- open_data:

  Logical. Whether or not to include the original data, 'data.csv', if
  this file exists. If `open_data = FALSE` and an open data file does
  exist, then it is excluded from the `.zip` file. If it does not yet
  exist, a synthetic data set is generated and added to the `.zip` file.

## Value

Logical, indicating the success of the operation. This function is
called for its side effect of creating a `.zip` file.

## Examples

``` r
export_project(worcs_directory = tempdir())
```
