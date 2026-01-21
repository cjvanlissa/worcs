# Add testthat to WORCS Project

Wraps
[use_testthat](https://usethis.r-lib.org/reference/use_testthat.html) to
add integration testing to a WORCS Project.

As `testthat` is primarily geared towards integration tests for 'R'
packages, this function conducts `testthat` test for WORCS projects.

## Usage

``` r
add_testthat(worcs_directory = ".", ...)

test_worcs(worcs_directory = ".", ...)
```

## Arguments

- worcs_directory:

  PARAM_DESCRIPTION, Default: '.'

- ...:

  Additional arguments passed to other functions.

## Value

No return value. This function is called for its side effects.

No return value. This function is called for its side effects.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE) &
  requireNamespace("testthat", quietly = TRUE)){
withr::with_tempdir({
  usethis::create_project(path = ".", rstudio = FALSE, open = FALSE)
  add_testthat()
})
}
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/file2298c17bf9e".
#> ✔ Creating R/.
#> ✔ Writing a sentinel file .here.
#> ☐ Build robust paths within your project via `here::here()`.
#> ℹ Learn more at <https://here.r-lib.org>.
#> ✔ Setting active project to "<no active project>".
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/file2298c17bf9e".
#> ✔ Creating tests/testthat/.
#> ✔ Writing tests/testthat.R.
#> ☐ Call `usethis::use_test()` to initialize a basic test file and open it for
#>   editing.
#> ℹ Updating tests/testthat.R
#> ✔ Updating tests/testthat.R ... done
#> 
#> ℹ Run `worcs::github_action_testthat()` to add a GitHub action that evaluates
#>   the integration tests.
#> ✔ Setting active project to "<no active project>".
if(requireNamespace("withr", quietly = TRUE) &
  requireNamespace("testthat", quietly = TRUE)){
  tmpdr <- file.path(tempdir(), "testworcs")
  usethis::create_project(path = tmpdr, rstudio = FALSE, open = FALSE)
  usethis::with_project(tmpdr, {
  writeLines("", ".worcs")
  add_testthat()
  usethis::use_test(name = "testme", open = FALSE)
  test_worcs()
  })

}
#> ✔ Creating /tmp/Rtmpj0K1ti/testworcs/.
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/testworcs".
#> ✔ Creating R/.
#> ✔ Writing a sentinel file .here.
#> ☐ Build robust paths within your project via `here::here()`.
#> ℹ Learn more at <https://here.r-lib.org>.
#> ✔ Setting active project to "<no active project>".
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/testworcs".
#> ✔ Creating tests/testthat/.
#> ✔ Writing tests/testthat.R.
#> ☐ Call `usethis::use_test()` to initialize a basic test file and open it for
#>   editing.
#> ℹ Updating tests/testthat.R
#> ✔ Updating tests/testthat.R ... done
#> 
#> ℹ Run `worcs::github_action_testthat()` to add a GitHub action that evaluates
#>   the integration tests.
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/testworcs".
#> ✔ Writing tests/testthat/test-testme.R.
#> ☐ Edit tests/testthat/test-testme.R.
#> ℹ Loading tests/testthat.R
#> ✔ Loading tests/testthat.R ... done
#> 
#> ✔ | F W  S  OK | Context
#> 
#> ⠏ |          0 | testme                                                         
#> ✔ |          1 | testme
#> 
#> ══ Results ═════════════════════════════════════════════════════════════════════
#> [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
#> ✔ Setting active project to "/tmp/Rtmpj0K1ti/testworcs".
#> ✔ Setting active project to "<no active project>".
```
