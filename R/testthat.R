#' @title Add testthat to WORCS Project
#' @description Wraps \link[usethis]{use_testthat} to add integration testing to
#' a WORCS Project.
#' @param worcs_directory PARAM_DESCRIPTION, Default: '.'
#' @param ... Additional arguments passed to \link[usethis]{use_testthat}
#' @return No return value. This function is called for its side effects.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE) &
#'   requireNamespace("testthat", quietly = TRUE)){
#' withr::with_tempdir({
#'   usethis::create_project(path = ".", rstudio = FALSE, open = FALSE)
#'   add_testthat()
#' })
#' }
#' @rdname add_testthat
#' @export
#' @importFrom usethis with_project use_testthat
add_testthat <- function(worcs_directory = ".", ...){
  usethis::with_project(path = worcs_directory, code = {
    usethis::use_testthat(...)
    with_cli_try("Updating {.file tests/testthat.R}", {
      txt <- readLines("tests/testthat.R")
      txt <- txt[1:grep("library(testthat)", txt, fixed = TRUE)]
      txt <- c(txt, 'testthat::test_dir("tests/testthat")')
      writeLines(txt, "tests/testthat.R")
    })
    cli_msg("i" = "Run {.fn worcs::github_action_testthat} to add a GitHub action that evaluates the integration tests.")
  })
}

#' @title Run all tests in a WORCS Project
#' @description As `testthat` is primarily geared towards integration tests for
#' 'R' packages, this function conducts `testthat` test for WORCS projects.
#' @param worcs_directory PARAM_DESCRIPTION, Default: '.'
#' @param ... Additional arguments passed to other functions.
#' @return No return value. This function is called for its side effects.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE) &
#'   requireNamespace("testthat", quietly = TRUE)){
#'   tmpdr <- file.path(tempdir(), "testworcs")
#'   usethis::create_project(path = tmpdr, rstudio = FALSE, open = FALSE)
#'   usethis::with_project(tmpdr, {
#'   writeLines("", ".worcs")
#'   add_testthat()
#'   usethis::use_test(name = "testme", open = FALSE)
#'   test_worcs()
#'   })
#'
#' }
#' @rdname add_testthat
#' @export
#' @importFrom usethis with_project use_testthat
test_worcs <- function(worcs_directory = ".", ...){
  checkworcs(worcs_directory = worcs_directory, iserror = TRUE)
  usethis::with_project(path = worcs_directory, code = {
    with_cli_try("Loading {.file tests/testthat.R}", {
      test_path <- file.path("tests", "testthat.R")
      if(!file.exists(test_path)) stop()
    })
    source(test_path)
  })
}
