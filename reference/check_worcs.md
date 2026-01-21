# Evaluate project with respect to WORCS checklist

Evaluates whether a project meets the criteria of the WORCS checklist
(see
[`worcs_checklist`](https://cjvanlissa.github.io/worcs/reference/worcs_checklist.md)).

## Usage

``` r
check_worcs(path = ".", verbose = TRUE)
```

## Arguments

- path:

  Character. Path to a WORCS project folder (a project with a `.worcs`
  file). Default: '.' (path to current directory).

- verbose:

  Logical. Whether or not to show status messages while evaluating the
  checklist. Default: `TRUE`.

## Value

A `data.frame` with a description of the criteria, and a column with
evaluations (`$pass`). For criteria that must be evaluated manually,
`$pass` will be `FALSE`.

## Examples

``` r
example_dir <- file.path(tempdir(), "badge")
dir.create(example_dir)
write("a", file.path(example_dir, ".worcs"))
check_worcs(path = example_dir)
#> ✖ Does the project have a README.md file?
#> ✖ Does the project have a LICENSE file?
#> ✖ Does the project cite any references in 'manuscript.Rmd' or
#>   'preregistration.Rmd'?
#> ✖ Does the project have a public* 'data.csv' or 'synthetic_data.csv' file?
#>   (*public: version controlled in 'Git')
#> ✖ Are the data checksums up to date?
#> ✖ Does the project contain any '.R' code files?
#> ✖ Does the project have a preregistration?
#> ✖ Does the project have a 'Git' repository?
#> ✖ Is the 'Git' repository connected to a remote repository (e.g., 'GitHub')?
#>           category              name
#> 1    documentation            readme
#> 2    documentation           license
#> 3         citation          citation
#> 4         citation     comprehensive
#> 5             data              data
#> 6             data    data_checksums
#> 7             code              code
#> 8             code code_reproducible
#> 9        materials         materials
#> 10          design            design
#> 11        analysis          analysis
#> 12 preregistration   preregistration
#> 13 preregistration   prereg_analysis
#> 14             git          git_repo
#> 15             git        has_remote
#>                                                                                                          description
#> 1                                                                            Does the project have a README.md file?
#> 2                                                                              Does the project have a LICENSE file?
#> 3                                 Does the project cite any references in 'manuscript.Rmd' or 'preregistration.Rmd'?
#> 4            Does the project cite all literature, data sources, materials, and methods (including R-packages) used?
#> 5    Does the project have a public* 'data.csv' or 'synthetic_data.csv' file? (*public: version controlled in 'Git')
#> 6                                                                                 Are the data checksums up to date?
#> 7                                                                      Does the project contain any '.R' code files?
#> 8  Can the entire project be reproduced by running a single file (e.g.,'manuscript.Rmd', 'run_me.R', or a Makefile)?
#> 9                                            Any new materials are shared openly; existing materials are referenced.
#> 10                                                                       Details of the study design are documented.
#> 11                                                                           Details of the analysis are documented.
#> 12                                                                          Does the project have a preregistration?
#> 13                                     Does the preregistration contain detailed analysis plans or preliminary code?
#> 14                                                                         Does the project have a 'Git' repository?
#> 15                                        Is the 'Git' repository connected to a remote repository (e.g., 'GitHub')?
#>    importance check  pass
#> 1   essential  TRUE FALSE
#> 2   essential  TRUE FALSE
#> 3    optional  TRUE FALSE
#> 4    optional FALSE FALSE
#> 5   essential  TRUE FALSE
#> 6   essential  TRUE FALSE
#> 7   essential  TRUE FALSE
#> 8    optional FALSE FALSE
#> 9    optional FALSE FALSE
#> 10  essential FALSE FALSE
#> 11  essential FALSE FALSE
#> 12   optional  TRUE FALSE
#> 13   optional FALSE FALSE
#> 14  essential  TRUE FALSE
#> 15  essential  TRUE FALSE
```
