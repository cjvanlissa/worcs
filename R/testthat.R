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
    worcs:::with_cli_try("Updating {.file tests/testthat.R}", {
      txt <- readLines("tests/testthat.R")
      txt <- txt[1:grep("library(testthat)", txt, fixed = TRUE)]
      txt <- c(txt, 'testthat::test_dir("testthat")')
      writeLines(txt, "tests/testthat.R")
    })
    worcs:::cli_msg("i" = "Run {.fn worcs::github_action_testthat} to add a GitHub action that evaluates the integration tests.")
  })
}
