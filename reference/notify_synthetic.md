# Notify the user when synthetic data are being used

This function prints a notification message when some or all of the data
used in a project are synthetic (see
[`closed_data`](https://cjvanlissa.github.io/worcs/reference/closed_data.md)
and
[`synthetic`](https://cjvanlissa.github.io/worcs/reference/synthetic.md)).
See details for important information.

## Usage

``` r
notify_synthetic(..., msg = NULL, worcs_directory = ".")
```

## Arguments

- ...:

  Objects of class `worcs_data`. The function will check if these are
  original or synthetic data.

- msg:

  Expression containing the message to print in case not all
  `worcs_data` are original.

- worcs_directory:

  Character, indicating the WORCS project directory to which to save
  data. The default value `"."` points to the current directory.

## Value

No return value. This function is called for its side effect of printing
a notification message.

## Details

The preferred way to use this function is to provide specific data
objects in the function call, using the `...` argument. If no such
objects are provided, `notify_synthetic` will scan the parent
environment for objects of class `worcs_data`.

This function is emphatically designed to be included in an 'R Markdown'
file, to dynamically generate a notification message when a third party
'Knits' such a document without having access to all original data.

## See also

closed_data synthetic add_synthetic

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)){
  withr::with_tempdir({
    file.create(".worcs")
    df <- iris
    class(df) <- c("worcs_data", class(df))
    attr(df, "type") <- "synthetic"
    result <- capture.output(notify_synthetic(df, msg = "it is synthetic"))
    if(!grepl("synthetic", result)) stop()
    df <- df[1:10, ]
    closed_data(df, codebook = NULL)
    file.remove("df.csv")
    result <- capture.output(notify_synthetic(msg = "synthetic"))
    if(!grepl("synthetic", result)) stop()
    if(requireNamespace("rmarkdown", quietly = TRUE)){
    add_manuscript(manuscript = "github_document")
    print(readLines("manuscript/manuscript.Rmd"))
    rmarkdown::render("manuscript/manuscript.Rmd")
    if(!any(grepl("reproduced using synthetic",
    readLines("manuscript/manuscript.html")))) stop()
    }
  })
}
#> ✔ Storing original data in 'df.csv' and updating the checksum in '.worcs'.
#> ✔ Generating synthetic data for public use. Ensure that no identifying
#>   information is included.
#>   |                                                                              |                                                                      |   0%  |                                                                              |==============                                                        |  20%  |                                                                              |============================                                          |  40%  |                                                                              |==========================================                            |  60%  |                                                                              |========================================================              |  80%
#> Warning: Dropped unused factor level(s) in dependent variable: versicolor, virginica.
#>   |                                                                              |======================================================================| 100%
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Updating '.gitignore'.
#> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> ✔ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
#> 
#> ✔ Updating '.gitignore'.
#> ✔ Storing value labels in 'value_labels_df.yml'.
#> ✔ Creating manuscript files.
#>  [1] "---"                                                                                                                                                                                                                  
#>  [2] "title: \"Untitled\""                                                                                                                                                                                                  
#>  [3] "output: github_document"                                                                                                                                                                                              
#>  [4] "date: '`r format(Sys.time(), \"%d %B, %Y\")`'"                                                                                                                                                                        
#>  [5] "bibliography: references.bib"                                                                                                                                                                                         
#>  [6] "knit: worcs::cite_all"                                                                                                                                                                                                
#>  [7] "---"                                                                                                                                                                                                                  
#>  [8] ""                                                                                                                                                                                                                     
#>  [9] "```{r setup, include=FALSE}"                                                                                                                                                                                          
#> [10] "library(\"worcs\")"                                                                                                                                                                                                   
#> [11] "# We recommend that you prepare your raw data for analysis in 'prepare_data.R',"                                                                                                                                      
#> [12] "# and end that file with either open_data(yourdata), or closed_data(yourdata)."                                                                                                                                       
#> [13] "# Then, uncomment the line below to load the original or synthetic data"                                                                                                                                              
#> [14] "# (whichever is available), to allow anyone to reproduce your code:"                                                                                                                                                  
#> [15] "# load_data()"                                                                                                                                                                                                        
#> [16] "knitr::opts_chunk$set(echo = TRUE)"                                                                                                                                                                                   
#> [17] "```"                                                                                                                                                                                                                  
#> [18] ""                                                                                                                                                                                                                     
#> [19] "This manuscript uses the Workflow for Open Reproducible Code in Science [WORCS version 0.1.20, @vanlissaWORCSWorkflowOpen2021] to ensure reproducibility and transparency."                                           
#> [20] ""                                                                                                                                                                                                                     
#> [21] ""                                                                                                                                                                                                                     
#> [22] "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2021]. If you change the rendering function to `worcs::cite_essential`, it will be removed."                                               
#> [23] ""                                                                                                                                                                                                                     
#> [24] "<!--The function below inserts a notification if the manuscript is knit using synthetic data.-->"                                                                                                                     
#> [25] "`r notify_synthetic()`"                                                                                                                                                                                               
#> [26] ""                                                                                                                                                                                                                     
#> [27] "## GitHub Documents"                                                                                                                                                                                                  
#> [28] ""                                                                                                                                                                                                                     
#> [29] "This is an R Markdown format used for publishing markdown documents to GitHub. When you click the **Knit** button all R code chunks are run and a markdown file (.md) suitable for publishing to GitHub is generated."
#> [30] ""                                                                                                                                                                                                                     
#> [31] "## Including Code"                                                                                                                                                                                                    
#> [32] ""                                                                                                                                                                                                                     
#> [33] "You can include R code in the document as follows:"                                                                                                                                                                   
#> [34] ""                                                                                                                                                                                                                     
#> [35] "```{r cars}"                                                                                                                                                                                                          
#> [36] "summary(cars)"                                                                                                                                                                                                        
#> [37] "```"                                                                                                                                                                                                                  
#> [38] ""                                                                                                                                                                                                                     
#> [39] "## Including Plots"                                                                                                                                                                                                   
#> [40] ""                                                                                                                                                                                                                     
#> [41] "You can also embed plots, for example:"                                                                                                                                                                               
#> [42] ""                                                                                                                                                                                                                     
#> [43] "```{r pressure, echo=FALSE}"                                                                                                                                                                                          
#> [44] "plot(pressure)"                                                                                                                                                                                                       
#> [45] "```"                                                                                                                                                                                                                  
#> [46] ""                                                                                                                                                                                                                     
#> [47] "Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot."                                                                                        
#> 
#> 
#> processing file: manuscript.Rmd
#> 1/7           
#> 2/7 [setup]   
#> 3/7           
#> 4/7 [cars]    
#> 5/7           
#> 6/7 [pressure]
#> 7/7           
#> output file: manuscript.knit.md
#> /opt/hostedtoolcache/pandoc/3.1.11/x64/pandoc +RTS -K512m -RTS manuscript.knit.md --to gfm+tex_math_dollars-yaml_metadata_block --from markdown+autolink_bare_uris+tex_math_single_backslash --output manuscript.md --template /home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/default.md --citeproc 
#> /opt/hostedtoolcache/pandoc/3.1.11/x64/pandoc +RTS -K512m -RTS manuscript.md --to html4 --from gfm+tex_math_dollars --output manuscript.html --embed-resources --standalone --highlight-style pygments --template /home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/preview.html --variable 'github-markdown-css:/home/runner/work/_temp/Library/rmarkdown/rmarkdown/templates/github_document/resources/github.css' --metadata pagetitle=PREVIEW --mathjax 
#> 
#> Preview created: manuscript.html
#> 
#> Output created: manuscript.md
```
