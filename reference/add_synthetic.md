# Add synthetic data to WORCS project

This function adds a user-specified synthetic data resource for public
use to a WORCS project with closed data.

## Usage

``` r
add_synthetic(
  data,
  synthetic_name = paste0("synthetic_", original_name),
  original_name,
  worcs_directory = ".",
  verbose = TRUE,
  ...
)
```

## Arguments

- data:

  A `data.frame` containing the synthetic data.

- synthetic_name:

  Character, naming the file synthetic data should be written to. By
  default, prepends `"synthetic_"` to the `original_name`.

- original_name:

  Character, naming an existing data resource in the WORCS project with
  which to associate the synthetic `data` object.

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value `"."` points to the current directory.

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

- ...:

  Additional arguments passed to and from functions.

## Value

Returns `NULL` invisibly. This function is called for its side effects.

## See also

open_data closed_data save_data

## Examples

``` r
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "add_synthetic")
dir.create(test_dir)
setwd(test_dir)
worcs:::write_worcsfile(".worcs")
# Prepare data
df <- iris[1:3, ]
# Run closed_data without synthetic
closed_data(df, codebook = NULL, synthetic = FALSE)
#> ✔ Storing original data in 'df.csv' and updating the checksum in '.worcs'.
#> ✔ Updating '.gitignore'.
#> ✔ Storing value labels in 'value_labels_df.yml'.
# Manually add synthetic
add_synthetic(df, original_name = "df.csv")
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Updating '.gitignore'.
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> 
# Remove original from file and environment
file.remove("df.csv")
#> [1] TRUE
rm(df)
# See that load_data() now loads the synthetic file
load_data()
#> ✔ Loading synthetic data from 'synthetic_df.csv'.
#> ✖ No valid codebook found.
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
```
