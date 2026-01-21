# Create codebook for a dataset

Creates a codebook for a dataset in 'R Markdown' format, and renders it
to 'markdown' for 'GitHub'. A codebook contains metadata and
documentation for a data file. We urge users to customize the
automatically generated 'R Markdown' document and re-knit it, for
example, to add a paragraph with details on the data collection
procedures. The variable descriptives are stored in a `.csv` file, which
can be edited in 'R' or a spreadsheet program. Columns can be appended,
and we encourage users to complete at least the following two columns in
this file:

- category:

  Describe the type of variable in this column. For example: "morality".

- description:

  Provide a plain-text description of the variable. For example, the
  full text of a questionnaire item: "People should be willing to do
  anything to help a member of their family".

Re-knitting the 'R Markdown' file (using
[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html))
will transfer these changes to the 'markdown' file for 'GitHub'.

## Usage

``` r
make_codebook(
  data,
  filename = "codebook.Rmd",
  render_file = TRUE,
  csv_file = gsub("rmd$", "csv", filename, ignore.case = TRUE),
  verbose = TRUE
)
```

## Arguments

- data:

  A data.frame for which to create a codebook.

- filename:

  Character. File name to write the codebook `rmarkdown` file to.

- render_file:

  Logical. Whether or not to render the document.

- csv_file:

  Character. File name to write the codebook `rmarkdown` file to. By
  default, uses the filename stem of the `filename` argument. Set to
  `NULL` to write the codebook only to the 'R Markdown' file, and not to
  `.csv`.

- verbose:

  Logical. Whether or not to print status messages to the console.
  Default: TRUE

## Value

`Logical`, indicating whether or not the operation was successful. This
function is mostly called for its side effect of rendering an 'R
Markdown' codebook.

## Examples

``` r
if(rmarkdown::pandoc_available("2.0")){
  library(rmarkdown)
  library(knitr)
  filename <- tempfile("codebook", fileext = ".Rmd")
  make_codebook(iris, filename = filename, csv_file = NULL)
  unlink(c(
    ".worcs",
    filename,
    gsub("\\.Rmd", "\\.md", filename),
    gsub("\\.Rmd", "\\.html", filename),
    gsub("\\.Rmd", "_files", filename)
  ), recursive = TRUE)
}
```
