# Using Endpoints to Check Reproducibility

``` r
library(worcs)
#> Welcome to WORCS: Workflow for Open Reproducible Code in Science. Run
#> `check_worcs_installation()` to make sure all dependencies are installed. For
#> more information, see the package vignettes
#> (<https://cjvanlissa.github.io/worcs/articles>) and accompanying
#> paper: Van Lissa and colleagues (2020)
#> (<https://doi.org/10.3233/DS-210031>)
```

This vignette describe the `worcs` package’s functionality for
automating reproducibility. The basic idea is that the entry point,
endpoint (or endpoints), and recipe by which to get to the endpoint from
the entry point are all well-defined.

In a typical `worcs` project, the entry point will be a dynamic document
(e.g., `manuscript.Rmd`), and the endpoint will be the rendered
manuscript (e.g., `manuscript.pdf`). The recipe by which to get from the
entry point to the endpoint is often a simple call to
`rmarkdown::render("manuscript.Rmd")`.

By default, the entry point and recipe are documented in the `.worcs`
project file when the project is created, if an R-script or Rmarkdown
file is selected as the manuscript. Endpoints are not created by
default, as it only makes sense to define them when the analyses are
complete.

Custom recipes can be added to a project using
[`add_recipe()`](https://cjvanlissa.github.io/worcs/reference/add_recipe.md).

## Adding endpoints

Users can add endpoints using the function `add_endpoint("filename")`.
When running this function, `filename` is added to the `.worcs` project
file, and its checksum is computed so that any changes to the contents
of the file can be detected. Note that checksums change in response to
*any* change to a file, no matter how trivial it may seem to us. Thus,
if there is any randomness in your analysis (ranging from Monte Carlo
estimation, bootstrapping, or even just jittering dots in a plot), or
any rounding error down to the 15th decimal, the checksum will change.
Be mindful of this, and only add endpoints that you are quite sure will
not vary due to randomness.

It is possible to specify multiple endpoints. For example, maybe the
user has finalized the analyses, and wants to track reproducibility for
the analysis results - but still wants to make changes to the text of
the manuscript without breaking reproducibility checks. In this case, it
is useful to track files that contain analysis results instead of the
rendered manuscript. Imagine these are intermediary files with analysis
results:

- `descriptives.csv`: A file with the descriptive statistics of study
  variables
- `model_fit.csv`: A table with model fit indices for several models
- `finalmodel.RData`: An RData file with the results of the final model

These three files could be tracked as endpoints by calling
`add_endpoint("descriptives.csv"); add_endpoint("model_fit.csv"); add_endpoint("finalmodel.RData")`.

## Integration Tests as Endpoints

The R-package `testthat` allows users to specify “integration tests” -
checks that verify that a given operation yields the expected result.
Integration tests are commonplace in software development, but they are
evidently also useful in research.

For example, if you write your own function to conduct an analysis, you
may want to test it on some synthetic data to make sure that it behaves
as expected.

Integration tests are also useful to check reproducibility: while
checksums change in response to any trivial change to a file, tests can
explicitly allow for rounding error.

For example, imagine that you conduct the following analysis:

``` r
# Run analysis
res <- lm(Sepal.Length ~ Sepal.Width + Petal.Length, iris)
# Extract regression coefficients
tab_coef <- summary(res)$coefficients
# Write to file
write.csv(tab_coef, "tab_coef.csv")
# Get checksum for file
digest::digest("tab_coef.csv")
#> [1] "124f039ae361721bb8a6d137f50a7b73"
```

Now, if we just round these results to the 15th decimal, the checksum
will be different:

``` r
# Write to file
write.csv(round(tab_coef, digits = 15), "tab_coef2.csv")
# Get checksum for file
digest::digest("tab_coef2.csv")
#> [1] "02989acb201b1208f822a0e05a9be96a"
```

This is not a trivial example: different computer hardware rounds
numbers differently in the high decimals. Therefore, using
`tab_coef.csv` as an endpoint could result in failure to reproduce, even
if it is essentially the same.

An integration test, by contrast, can allow for rounding error, and
would allow the same comparison to pass. Here, I use a three-decimal
tolerance:

``` r
testthat::expect_equal(tab_coef, round(tab_coef, digits = 15), tolerance = 1e-3)
```

### Adding Integration Tests

To set up a test suite for your project, run:

``` r
worcs::add_testthat()
```

Next, you will have to write each of the tests you want to conduct to
its own file. Call this functions to set up your first test file:

``` r
usethis::use_test("my_first_test.R")
```

By default, the tests are not added as endpoints - but you can run them
interactively with the function
[`worcs::test_worcs()`](https://cjvanlissa.github.io/worcs/reference/add_testthat.md).
If you want to add them as endpoints, simply pass the argument
`"testthat"` to the endpoints function:

``` r
worcs::add_endpoint("testthat")
```

After doing so, reproducing the project (see next section) will also run
the integration test suite.

## Reproducing a Project

A WORCS project can be reproduced by evaluating the function
[`reproduce()`](https://cjvanlissa.github.io/worcs/reference/reproduce.md).
This function evaluates the recipe defined in the `.worcs` project file.
If no recipe is specified (e.g., when a project was created with an
older version of the package), but an entry point is defined,
[`reproduce()`](https://cjvanlissa.github.io/worcs/reference/reproduce.md)
will try to evaluate the entry point if it is an Rmarkdown or R source
file.

## Checking reproducibility

Users can verify that the endpoint remains unchanged after reproducing
the project by calling the function
[`check_endpoints()`](https://cjvanlissa.github.io/worcs/reference/check_endpoints.md).
If any endpoint has changed relative to the version stored in the
`.worcs` project file, this will result in a warning message.

## Updating endpoints

To update the endpoints in the `.worcs` file, call
[`snapshot_endpoints()`](https://cjvanlissa.github.io/worcs/reference/snapshot_endpoints.md).
Always call this function to log changes to the code that should result
in a different end result.

## Automating Reproducibility

If a project is connected to a remote repository on GitHub, it is
possible to use GitHub actions to automatically check a project’s
reproducibility and signal the result of this reproducibility check by
displaying a badge on the project’s readme page (which is the welcome
page visitors of the GitHub repository first see).

To do so, follow these steps:

1.  Add endpoint using add_endpoint(); for example, if the endpoint of
    your analyses is a file called `'manuscript/manuscript.md'`, then
    you would call `add_endpoint('manuscript/manuscript.md')`
2.  Run
    [`github_action_reproduce()`](https://cjvanlissa.github.io/worcs/reference/github_action_check_endpoints.md)
3.  You should see a message asking you to copy-paste code for a status
    badge to your `readme.md`. If you do not see this message, add the
    following code to your readme.md manually:
    - `[![worcs_endpoints](https://github.com/YOUR_ACCOUNT/PROJECT_REPOSITORY/actions/workflows/worcs_reproduce.yaml/badge.svg)](https://github.com/YOUR_ACCOUNT/PROJECT_REPOSITORY/actions/worcs_reproduce.yaml/worcs_endpoints.yaml)`
4.  Commit these changes to GitHub using
    [`git_update()`](https://cjvanlissa.github.io/worcs/reference/git_update.md)

Visit your project page on GitHub and select the `Actions` tab to see
that your reproducibility check is running; visit the main project page
to see the new badge in your readme.md file.

## Automating Endpoint Checks

Sometimes, you may wish to verify that the endpoints of a project remain
the same but without reproducing all analyses on GitHub’s servers. This
may be the case when the project has closed data that are not available
on GitHub, or if the analyses take a long time to compute and you want
to prevent using unnecessary compute power (e.g., for environmental
reasons).

In these cases, you can still use GitHub actions to automatically check
whether the endpoints have remained unchanged. If your local changes to
the project introduce deviations from the endpoint snapshots, these
tests will fail.

If you make intentional changes to the endpoints, you should of course
run
[`snapshot_endpoints()`](https://cjvanlissa.github.io/worcs/reference/snapshot_endpoints.md).

You can display a badge on the project’s readme page to signal that the
endpoints remain unchanged.

To do so, follow these steps:

1.  Add endpoint using add_endpoint(); for example, if the endpoint of
    your analyses is a file called `'manuscript/manuscript.md'`, then
    you would call `add_endpoint('manuscript/manuscript.md')`
2.  Run
    [`github_action_check_endpoints()`](https://cjvanlissa.github.io/worcs/reference/github_action_check_endpoints.md)
3.  You should see a message asking you to copy-paste code for a status
    badge to your `readme.md`. If you do not see this message, add the
    following code to your readme.md manually:
    - `[![worcs_endpoints](https://github.com/YOUR_ACCOUNT/PROJECT_REPOSITORY/actions/workflows/worcs_endpoints.yaml/badge.svg)](https://github.com/YOUR_ACCOUNT/PROJECT_REPOSITORY/actions/workflows/worcs_endpoints.yaml)`
4.  Commit these changes to GitHub using
    [`git_update()`](https://cjvanlissa.github.io/worcs/reference/git_update.md)

Visit your project page on GitHub and select the `Actions` tab to see
that your reproducibility check is running; visit the main project page
to see the new badge in your readme.md file.
