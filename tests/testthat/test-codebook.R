test_that("codebook works for iris", {

  the_test <- "codebook"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)

  worcs::make_codebook(iris)

  expect_true(file.exists("codebook.Rmd"))
  expect_true(file.exists("codebook.md"))

  contents <- readLines("codebook.md")

  expect_true(any(contents == "The data contains 150 cases and 5 variables."))

  setwd(old_wd)
  unlink(test_dir, recursive = TRUE)
})


test_that("codebook works for PlantGrowth with missings", {
  df <- PlantGrowth
  df[c(7:8), 1] <- NA
  df[c(1, 25), 2] <- NA
  the_test <- "codebook"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)

  worcs::make_codebook(df)

  expect_true(file.exists("codebook.Rmd"))
  expect_true(file.exists("codebook.md"))

  contents <- readLines("codebook.md")

  expect_true(any(contents == "The data contains 30 cases and 2 variables."))

  setwd(old_wd)
  unlink(test_dir, recursive = TRUE)
})
