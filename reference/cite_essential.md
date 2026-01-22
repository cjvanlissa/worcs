# Essential citations Knit function for 'RStudio'

This is a wrapper for
[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
First, this function parses the citations in the document, removing
citations marked with double at sign, e.g.: `@@reference2020`. Then, it
renders the file.

## Usage

``` r
cite_essential(...)
```

## Arguments

- ...:

  All arguments are passed to
  [`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Value

Returns `NULL` invisibly. This function is called for its side effect of
rendering an 'R Markdown' file.

## Examples

``` r
# NOTE: Do not use this function interactively, as in the example below.
# Only specify it as custom knit function in an R Markdown file, like so:
# knit: worcs::cite_all

if (rmarkdown::pandoc_available("2.0")){
  file_name <- tempfile("citeessential", fileext = ".Rmd")
  rmarkdown::draft(file_name,
                   template = "github_document",
                   package = "rmarkdown",
                   create_dir = FALSE,
                   edit = FALSE)
  write(c("", "Optional reference: @reference2020"),
        file = file_name, append = TRUE)
  cite_essential(file_name)
}
#> 
#> 
#> processing file: citeessential20e3410f9f4a.Rmd
#> 1/7           
#> 2/7 [setup]   
#> 3/7           
#> 4/7 [cars]    
#> 5/7           
#> 6/7 [pressure]
#> 7/7           
#> output file: citeessential20e3410f9f4a.knit.md
#> /opt/hostedtoolcache/pandoc/3.1.11/x64/pandoc +RTS -K512m -RTS citeessential20e3410f9f4a.knit.md --to gfm+tex_math_dollars-yaml_metadata_block --from markdown+autolink_bare_uris+tex_math_single_backslash --output citeessential20e3410f9f4a.md --template /home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/default.md 
#> /opt/hostedtoolcache/pandoc/3.1.11/x64/pandoc +RTS -K512m -RTS citeessential20e3410f9f4a.md --to html4 --from gfm+tex_math_dollars --output citeessential20e3410f9f4a.html --embed-resources --standalone --highlight-style pygments --template /home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/preview.html --variable 'github-markdown-css:/home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/github.css' --metadata pagetitle=PREVIEW --mathjax 
#> 
#> Preview created: citeessential20e3410f9f4a.html
#> 
#> Output created: citeessential20e3410f9f4a.md
```
