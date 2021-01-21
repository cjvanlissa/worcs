test_that("codebook works for iris", {

  old_wd <- getwd()
  test_dir <- file.path(tempdir(), "codebook")
  dir.create(test_dir)
  setwd(test_dir)

  worcs::make_codebook(iris)

  expect_true(file.exists("codebook.Rmd"))
  if (rmarkdown::pandoc_available("1.12.3")){
    expect_true(file.exists("codebook.md"))
  }
  expect_true(file.exists("codebook.csv"))
  contents <- readLines("codebook.Rmd", encoding = "UTF-8")
  expect_true(any(contents == "The data contains 150 cases and 5 variables."))

  setwd(old_wd)
  unlink(test_dir, recursive = TRUE)
})

if(TRUE){
test_that("codebook works for PlantGrowth with missings", {
  df <- CO2
  df[c(7:8), 1] <- NA
  df[c(1, 25), 2] <- NA

  old_wd <- getwd()
  test_dir <- file.path(tempdir(), "codebook")
  dir.create(test_dir)
  setwd(test_dir)

  worcs::make_codebook(df)
  expect_true(file.exists("codebook.Rmd"))
  if (rmarkdown::pandoc_available("1.12.3")){
    expect_true(file.exists("codebook.md"))
  }

  contents <- readLines("codebook.Rmd", encoding = "UTF-8")

  expect_true(any(contents == "The data contains 84 cases and 5 variables.")) #"The data contains 30 cases and 2 variables."))

  setwd(old_wd)
  unlink(test_dir, recursive = TRUE)
})
}
