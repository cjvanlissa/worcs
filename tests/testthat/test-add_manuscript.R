test_that("manuscript can be generated", {
  library(rticles)
  the_test <- "manuscript"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  file.create(file.path(tempdir(), the_test, ".worcs"))
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  add_manuscript(
    worcs_directory = ".",
    manuscript = "github_document",
    remote_repo = "bla"
  )
  expect_true(dir.exists("manuscript"))
  expect_true(file.exists(".worcs"))
  #expect_true(file.exists("manuscript/american-chemical-society.csl"))
  expect_true(file.exists("manuscript/manuscript.Rmd"))
  expect_true(file.exists("manuscript/references.bib"))
  setwd(old_wd)
})
