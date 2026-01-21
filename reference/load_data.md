# Load WORCS project data

Scans the WORCS project file for data that have been saved using
[`open_data`](https://cjvanlissa.github.io/worcs/reference/open_data.md)
or
[`closed_data`](https://cjvanlissa.github.io/worcs/reference/closed_data.md),
and loads these data into the global (working) environment. The function
will load the original data if available on the current system. If only
a synthetic dataset is available, this function loads the synthetic
data. The name of the object containing the data is derived from the
file name by removing the file extension, and, when applicable, the
prefix `"synthetic_"`. Thus, both `"data.csv"` and
`"synthetic_data.csv"` will be loaded into an object called `data`.

## Usage

``` r
load_data(
  worcs_directory = ".",
  to_envir = TRUE,
  envir = parent.frame(1),
  verbose = TRUE,
  use_metadata = TRUE
)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory from which to load
  data. The default value `"."` points to the current directory.

- to_envir:

  Logical, indicating whether to load objects directly into the
  environment, or return a [`list`](https://rdrr.io/r/base/list.html)
  containing the objects. The environment is designated by argument
  `envir`. Loading objects directly into the global environment is
  user-friendly, but has the risk of overwriting an existing object with
  the same name, as explained in
  [`load`](https://rdrr.io/r/base/load.html). The function `load_data`
  gives a warning when this happens.

- envir:

  The environment where the data should be loaded. The default value
  `parent.frame(1)` refers to the global environment in an interactive
  session.

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

- use_metadata:

  Logical. Whether or not to use the codebook and value labels and
  attempt to coerce the class and values of variables to those recorded
  therein. Default: TRUE

## Value

Returns a list invisibly. If `to_envir = TRUE`, this list contains the
loaded data files. If `to_envir = FALSE`, the list is empty, and the
loaded data files are attached directly to the global environment.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
  withr::with_tempdir({
    file.create(".worcs")
    df <- iris[1:5, ]
    df$Species <- droplevels(df$Species)
    closed_data(df, codebook = NULL)
    temp_env <- new.env()
    load_data(envir = temp_env)
    rm("df", envir = temp_env)
    file.remove("df.csv")
    load_data(envir = temp_env)
  })
}
#> ✔ Storing original data in 'df.csv' and updating the checksum in '.worcs'.
#> ✔ Generating synthetic data for public use. Ensure that no identifying
#>   information is included.
#>   |                                                                              |                                                                      |   0%  |                                                                              |==============                                                        |  20%  |                                                                              |============================                                          |  40%  |                                                                              |==========================================                            |  60%  |                                                                              |========================================================              |  80%  |                                                                              |======================================================================| 100%
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Updating '.gitignore'.
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> 
#> ✔ Updating '.gitignore'.
#> ✔ Storing value labels in 'value_labels_df.yml'.
#> ✔ Loading original data from 'df.csv'.
#> ✖ No valid codebook found.
#> ✔ Loading synthetic data from 'synthetic_df.csv'.
#> ✖ No valid codebook found.
```
