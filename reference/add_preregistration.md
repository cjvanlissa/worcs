# Add Rmarkdown preregistration

Adds an Rmarkdown preregistration template to a 'worcs' project.

## Usage

``` r
add_preregistration(
  worcs_directory = ".",
  preregistration = "cos_prereg",
  verbose = TRUE,
  ...
)
```

## Arguments

- worcs_directory:

  Character, indicating the directory in which to create the manuscript
  files. Default: '.', which points to the current working directory.

- preregistration:

  Character, indicating what template to use for the preregistration.
  Default: `"cos_prereg"`; use `"None"` to omit a preregistration. See
  Details for other available choices.

- verbose:

  Logical. Whether or not to print messages to the console during
  project creation. Default: TRUE

- ...:

  Additional arguments passed to and from functions.

## Value

No return value. This function is called for its side effects.

## Details

Available choices include the templates from the
[`prereg`](https://rdrr.io/pkg/prereg/man/prereg.html) package, and
several unique templates included with `worcs`:

- `'PSS'`:

  Preregistration and Sharing Software (Krypotos, Klugkist, Mertens, &
  Engelhard, 2019)

- `'Secondary'`:

  Preregistration for secondary analyses (Mertens & Krypotos, 2019)

- `'aspredicted_prereg'`:

  aspredicted template from the `prereg` package

- `'brandt_prereg'`:

  brandt template from the `prereg` package

- `'cos_prereg'`:

  cos template from the `prereg` package

- `'fmri_prereg'`:

  fmri template from the `prereg` package

- `'prp_quant_prereg'`:

  prp_quant template from the `prereg` package

- `'psyquant_prereg'`:

  psyquant template from the `prereg` package

- `'rr_prereg'`:

  rr template from the `prereg` package

- `'vantveer_prereg'`:

  vantveer template from the `prereg` package

## Examples

``` r
the_test <- "worcs_prereg"
old_wd <- getwd()
dir.create(file.path(tempdir(), the_test))
file.create(file.path(tempdir(), the_test, ".worcs"))
#> [1] TRUE
add_preregistration(file.path(tempdir(), the_test),
                    preregistration = "cos_prereg")
#> ✔ Creating preregistration files.
setwd(old_wd)
unlink(file.path(tempdir(), the_test))
```
