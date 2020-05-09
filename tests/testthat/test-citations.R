library(rmarkdown)

test_that("documents with spaces in names can be rendered", {

  skip_on_cran()

  the_test <- "citeall"
  dir_name <- file.path(tempdir(), the_test)
  file_name <- file.path(dir_name, "test.Rmd")
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  draft(file_name, template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  write(c("", "Optional reference: @@reference2020"),
        file = file_name, append = TRUE)
  cite_all(file_name)

  contents <- readLines(gsub("Rmd$", "md", file_name))

  expect_true(any(contents == "Optional reference: @reference2020"))

  cite_essential(file_name)

  contents <- readLines(gsub("Rmd$", "md", file_name))

  expect_true(!any(contents == "Optional reference: @reference2020"))
  expect_true(any(contents == "Optional reference:"))
})
