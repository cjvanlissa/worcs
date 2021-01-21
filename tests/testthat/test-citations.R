library(rmarkdown)

test_that("documents with spaces in names can be rendered", {

  the_test <- "citeall"
  dir_name <- file.path(tempdir(), the_test)
  if(dir.exists(dir_name)) unlink(dir_name, recursive = TRUE)
  file_name <- file.path(dir_name, "test.Rmd")
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  draft(file_name, template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  write(c("", "Optional reference: @@reference2020"),
        file = file_name, append = TRUE)
  sink_out <- capture_output(cite_all(file_name))

  contents <- readLines(gsub("Rmd$", "md", file_name), encoding = "UTF-8")

  expect_true(any(contents == "Optional reference: @reference2020"))

  sink_out <- capture_output(cite_essential(file_name))

  contents <- readLines(gsub("Rmd$", "md", file_name), encoding = "UTF-8")

  expect_true(!any(contents == "Optional reference: @reference2020"))
  expect_true(any(contents == "Optional reference:"))
})

test_that("cite_* work with umlaute", {
  # stringi::stri_enc_detect(file_name) might be helpful?
  #skip_on_cran()

  the_test <- "citeall"
  dir_name <- file.path(tempdir(), the_test)
  if(dir.exists(dir_name)) unlink(dir_name, recursive = TRUE)
  file_name <- file.path(dir_name, "test.Rmd")
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  draft(file_name, template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  #write(c("", "Optional räference: @@reference2020"),
  #      file = file_name, append = TRUE)
  worcs:::write_as_utf(c("", "Optional räference: @@reference2020"),
                       con = file_name, append = TRUE)
  if (rmarkdown::pandoc_available("1.12.3")){
    sink_out <- capture_output(cite_all(file_name))
    md_file <- force(gsub("Rmd$", "md", file_name))
    contents <- worcs:::read_as_utf(md_file)

    expect_true(any(contents == "Optional räference: @reference2020"))

    sink_out <- capture_output(cite_essential(file_name))

    contents <- worcs:::read_as_utf(gsub("Rmd$", "md", file_name))

    expect_true(!any(contents == "Optional räference: @reference2020"))
    expect_true(any(contents == "Optional räference:"))
  }
})

test_that("cite_* retain relative paths", {

  #skip_on_cran()

  the_test <- "relative"
  dir_name <- file.path(tempdir(), the_test)
  if(dir.exists(dir_name)) unlink(dir_name, recursive = TRUE)
  file_name <- file.path(dir_name, "test.Rmd")
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  draft(file_name, template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  write(c("", "Optional reference: @@reference2020"),
        file = file_name, append = TRUE)

  write.csv(iris,  file.path(dir_name, "iris.csv"))

  write(c("",
"
```{r}
myiris <- read.csv('iris.csv')
```
"), file = file_name, append = TRUE)

  # Render with all citations
  if (rmarkdown::pandoc_available("1.12.3")){
    sink_out <- capture_output(cite_all(file_name))

    contents <- readLines(normalizePath(gsub("\\.Rmd", "\\.md", file_name)))

    expect_true(any(contents == "Optional reference: @reference2020"))

    sink_out <- capture_output(cite_essential(file_name))

    contents <- readLines(normalizePath(gsub("\\.Rmd", "\\.md", file_name)))

    expect_true(!any(contents == "Optional reference: @reference2020"))
    expect_true(any(grepl("myiris", contents, fixed = TRUE)))
    expect_true(any(contents == "Optional reference:"))
  }
})

test_that("cite_* retain double @", {

  #skip_on_cran()

  the_test <- "citeall"
  dir_name <- file.path(tempdir(), the_test)
  if(dir.exists(dir_name)) unlink(dir_name, recursive = TRUE)
  file_name <- file.path(dir_name, "test.Rmd")
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)

  draft(file_name, template = "github_document", package = "rmarkdown",
        create_dir = FALSE, edit = FALSE)

  write(c("", "Optional reference: @@reference2020"),
        file = file_name, append = TRUE)

  sink_out <- capture_output(cite_all(file_name))

  contents <- readLines(file_name, encoding = "UTF-8")

  expect_true(any(contents == "Optional reference: @@reference2020"))

  sink_out <- capture_output(cite_essential(file_name))

  contents <- readLines(file_name, encoding = "UTF-8")

  expect_true(any(contents == "Optional reference: @@reference2020"))
})
