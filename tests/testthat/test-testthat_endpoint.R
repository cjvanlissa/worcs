test_that("testthat works as endpoint", {
  worcs:::scoped_tempdir({
      library(testthat)
      worcs_project(path = ".", manuscript = "github_document", preregistration = "None", add_license = "None", use_renv = FALSE, use_targets = FALSE, remote_repo = "https", verbose = FALSE)
      add_testthat()
      #usethis::use_test(name = "test-mytest.R", open = FALSE)
      writeLines(c("test_that(\"multiplication works\", {", "  expect_equal(2 * 2, 4)", "})"), "tests/testthat/test-mytest.R")
      expect_true(worcs::reproduce())

      expect_true(check_endpoints())

      add_endpoint("testthat")

      expect_true(check_endpoints())

      add_endpoint("manuscript/manuscript.html")
      expect_true(check_endpoints())

      # lnz <- readLines("tests/testthat/test-mytest.R")
      # writeLines(gsub("2 * 2", "2 * 3", lnz, fixed = TRUE), "tests/testthat/test-mytest.R")
      # expect_error(check_endpoints())


  })
})
