library(rmarkdown)
# the_test <- "citeall"
# old_wd <- getwd()
# dir.create(file.path(tempdir(), the_test))
# setwd(file.path(tempdir(), "citeall"))
draft("test.Rmd", template = "github_document", package = "rmarkdown",
      create_dir = FALSE, edit = FALSE)

write(c("", "Optional reference: @@reference2020"),
      file = "test.Rmd", append = TRUE)
cite_all("test.Rmd", "UTF-8")

contents <- readLines("test.md")
test_that("Reference is retained correctly", {
  expect_true(any(contents == "Optional reference: @reference2020"))
})

cite_essential("test.Rmd", "UTF-8")

contents <- readLines("test.md")
test_that("Reference is retained correctly", {
  expect_true(!any(contents == "Optional reference: @reference2020"))
  expect_true(any(contents == "Optional reference:"))
})

# setwd(old_wd)
# unlink(file.path(tempdir(), the_test))
