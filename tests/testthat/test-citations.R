library(rmarkdown)

test_that("documents with spaces in names can be rendered", {

  skip_on_cran()

  the_test <- "citeall"
  dir_name <- file.path(tempdir(), the_test)
  file_name <- file.path(dir_name, "test.Rmd")
  old_wd <- getwd()
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  setwd(dir_name)
  draft("test.Rmd", template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  write(c("", "Optional reference: @@reference2020"),
        file = "test.Rmd", append = TRUE)
  cite_all("test.Rmd", "UTF-8")

  contents <- readLines("test.md")

  expect_true(any(contents == "Optional reference: @reference2020"))

  cite_essential("test.Rmd", "UTF-8")

  contents <- readLines("test.md")

  expect_true(!any(contents == "Optional reference: @reference2020"))
  expect_true(any(contents == "Optional reference:"))

  setwd(old_wd)
})
