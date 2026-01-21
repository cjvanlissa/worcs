# Load project entry points

Loads the designated project entry point into the default editor, using
[`file.edit`](https://rdrr.io/r/utils/file.edit.html).

## Usage

``` r
load_entrypoint(worcs_directory = ".", verbose = TRUE, ...)
```

## Arguments

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value `"."` points to the current directory.

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

- ...:

  Additional arguments passed to
  [`file.edit`](https://rdrr.io/r/utils/file.edit.html).

## Value

No return value. This function is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
if(requireNamespace("withr", quietly = TRUE)){
  withr::with_tempdir({
    # Prepare worcs file and dummy entry point
    worcs:::write_worcsfile(".worcs", entry_point = "test.txt")
    writeLines("Hello world", con = file("test.txt", "w"))
    # Demonstrate load_entrypoint()
    load_entrypoint()
  })
}
} # }
```
