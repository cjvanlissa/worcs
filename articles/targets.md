# Using targets to Reduce Redundant Computations

Code in reproducible projects is often executed much more often than in
non-reproducible projects. After each change, the entire analysis is
typically executed to check if its results still reproduce. While such
rigorous testing is integral to reproducibility [see ‘Using Endpoints to
Check
Reproducibility’](https://cjvanlissa.github.io/worcs/articles/endpoints.md),
executing unchanged code can be redundant. Moreover, if the analyses
take a long time, this can take the steam out of your sails if you are
in the flow, working on a project. Computing also has an environmental
footprint, and it is worth considering the trade-off between re-running
code sufficiently frequently to ensure its reproducibility, but not
needlessly beyond that (Gupta et al. 2021).

The [`targets` package](https://books.ropensci.org/targets/) addresses
this challenge. It facilitates defining and executing an analysis
pipeline, and tracks dependencies between blocks of code to ensure that
code is only re-run if it has changed, or if its input has changed.
Since version `0.1.15`, `worcs` facilitates the use of `targets` in
`worcs` projects. The `targets` package is perfectly complementary to
`worcs`, and this Vignette describes the two canonical ways of combining
the two. Since `targets` requires a specific way of working though,
please make sure to read the [`targets`
manual](https://books.ropensci.org/targets/) before jumping in.

## Defining a Pipeline

The canonical way of using `targets` in `worcs` is to select the “Use
Targets” checkbox in the “Create a Project” dialog window. Subsequently,
you would define the analysis pipeline in the `_targets.R` script file.
Running
[`worcs::reproduce()`](https://cjvanlissa.github.io/worcs/reference/reproduce.md),
or
[`targets::tar_make()`](https://docs.ropensci.org/targets/reference/tar_make.html),
will execute the steps in this script. The script often makes use of
analysis functions defined in the `R/` directory. Since the `worcs`
workflow recommends using dynamic document generation, the pipeline in
the `_targets.R` script will often end with rendering an `Rmarkdown` or
`Quarto` document. When adding `targets` to a `worcs` project, this line
is automatically added to the `_targets.R` script. Results from the
analysis pipeline can be loaded into the environment in the `Rmarkdown`
document using the `targets::tar_load(result_name)` or
[`targets::tar_load_everything()`](https://docs.ropensci.org/targets/reference/tar_load_everything.html)
functions.

## Using `targets` Markdown

Alternatively, is is possible to run `targets` entirely from within an
`Rmarkdown` file. To this end, either select the “target_markdown”
output format when creating a new `worcs` project, or select any other
output format and manually incorporate the `targets` pipeline, following
the [manual](https://books.ropensci.org/targets/markdown.html). A word
of warning however: combining the interactive execution of code chunks
while writing an Rmarkdown file with programmatic execution of a
pipeline using `tar_make()` is likely to be more prone to bugs than
**only** programmatically executing code.

Gupta, Udit, Young Geun Kim, Sylvia Lee, Jordan Tse, Hsien-Hsin S. Lee,
Gu-Yeon Wei, David Brooks, and Carole-Jean Wu. 2021. “Chasing Carbon:
The Elusive Environmental Footprint of Computing.” In *2021 IEEE
International Symposium on High-Performance Computer Architecture
(HPCA)*, 854–67. <https://doi.org/10.1109/HPCA51647.2021.00076>.
