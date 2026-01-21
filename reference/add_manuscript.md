# Add Rmarkdown manuscript

Adds an Rmarkdown manuscript to a 'worcs' project.

## Usage

``` r
add_manuscript(
  worcs_directory = ".",
  manuscript = "APA6",
  remote_repo = NULL,
  verbose = TRUE,
  ...
)
```

## Arguments

- worcs_directory:

  Character, indicating the directory in which to create the manuscript
  files. Default: '.', which points to the current working directory.

- manuscript:

  Character, indicating what template to use for the 'R Markdown'
  manuscript. Default: 'APA6'. Available choices include:
  `"APA6", "github_document", "None"` and the templates from the
  [`rticles`](https://pkgs.rstudio.com/rticles/reference/rticles-package.html)
  package. See Details.

- remote_repo:

  Character, 'https' link to the remote repository for this project.
  This link should have the form `https://[...].git`. This link will be
  inserted in the draft manuscript.

- verbose:

  Logical. Whether or not to print messages to the console during
  project creation. Default: TRUE

- ...:

  Additional arguments passed to and from functions.

## Value

No return value. This function is called for its side effects.

## Details

Available choices include the following manuscript templates:

- `'APA6'`:

  An APA6 style template from the `papaja` package

- `'github_document'`:

  A
  [`github_document`](https://pkgs.rstudio.com/rmarkdown/reference/github_document.html)
  from the `rmarkdown` package

- `'acm_article'`:

  acm style template from the `rtices` package

- `'acs_article'`:

  acs style template from the `rtices` package

- `'aea_article'`:

  aea style template from the `rtices` package

- `'agu_article'`:

  agu style template from the `rtices` package

- `'ajs_article'`:

  ajs style template from the `rtices` package

- `'amq_article'`:

  amq style template from the `rtices` package

- `'ams_article'`:

  ams style template from the `rtices` package

- `'arxiv_article'`:

  arxiv style template from the `rtices` package

- `'asa_article'`:

  asa style template from the `rtices` package

- `'bioinformatics_article'`:

  bioinformatics style template from the `rtices` package

- `'biometrics_article'`:

  biometrics style template from the `rtices` package

- `'copernicus_article'`:

  copernicus style template from the `rtices` package

- `'ctex_article'`:

  ctex style template from the `rtices` package

- `'elsevier_article'`:

  elsevier style template from the `rtices` package

- `'frontiers_article'`:

  frontiers style template from the `rtices` package

- `'glossa_article'`:

  glossa style template from the `rtices` package

- `'ieee_article'`:

  ieee style template from the `rtices` package

- `'ims_article'`:

  ims style template from the `rtices` package

- `'informs_article'`:

  informs style template from the `rtices` package

- `'iop_article'`:

  iop style template from the `rtices` package

- `'isba_article'`:

  isba style template from the `rtices` package

- `'jasa_article'`:

  jasa style template from the `rtices` package

- `'jedm_article'`:

  jedm style template from the `rtices` package

- `'joss_article'`:

  joss style template from the `rtices` package

- `'jss_article'`:

  jss style template from the `rtices` package

- `'lipics_article'`:

  lipics style template from the `rtices` package

- `'mdpi_article'`:

  mdpi style template from the `rtices` package

- `'mnras_article'`:

  mnras style template from the `rtices` package

- `'oup_article'`:

  oup style template from the `rtices` package

- `'peerj_article'`:

  peerj style template from the `rtices` package

- `'pihph_article'`:

  pihph style template from the `rtices` package

- `'plos_article'`:

  plos style template from the `rtices` package

- `'pnas_article'`:

  pnas style template from the `rtices` package

- `'rjournal_article'`:

  rjournal style template from the `rtices` package

- `'rsos_article'`:

  rsos style template from the `rtices` package

- `'rss_article'`:

  rss style template from the `rtices` package

- `'sage_article'`:

  sage style template from the `rtices` package

- `'sim_article'`:

  sim style template from the `rtices` package

- `'springer_article'`:

  springer style template from the `rtices` package

- `'tf_article'`:

  tf style template from the `rtices` package

- `'trb_article'`:

  trb style template from the `rtices` package

- `'wellcomeor_article'`:

  wellcomeor style template from the `rtices` package

## Examples

``` r
the_test <- "worcs_manuscript"
old_wd <- getwd()
dir.create(file.path(tempdir(), the_test))
file.create(file.path(tempdir(), the_test, ".worcs"))
#> [1] TRUE
add_manuscript(file.path(tempdir(), the_test),
              manuscript = "None")
#> ✔ Creating manuscript files.
setwd(old_wd)
unlink(file.path(tempdir(), the_test))
```
