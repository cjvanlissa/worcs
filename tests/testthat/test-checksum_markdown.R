test_that("checksum works from within Rmarkdown", {
  the_test <- "cs_markdown"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)


  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))
  dat <- iris[1:4,1:4]
  open_data(dat)
  cs_correct <- "44a5d36f15d4c85b2447395671a3ddf0"
  expect_true(worcs:::cs_fun(filename = file.path(test_dir, "dat.csv"), worcsfile = file.path(test_dir, ".worcs")) == cs_correct)
  dir.create(file.path(test_dir, "manuscript"))
  setwd(file.path(test_dir, "manuscript"))
  expect_true(worcs:::cs_fun(filename = file.path(test_dir, "dat.csv"), worcsfile = file.path(test_dir, ".worcs")) == cs_correct)
  man_txt <- c("---", "title: \"Untitled\"", "output: github_document", "---",
               "", "```{r setup}", "library(\"worcs\")", "load_data()", "```", "", "`r worcs:::cs_fun(file.path(dirname(worcs:::check_recursive(file.path(normalizePath('.')))), 'dat.csv'), file.path(dirname(worcs:::check_recursive(file.path(normalizePath('.')))), '.worcs'))`")
  writeLines(man_txt, "manuscript.rmd")
  rmarkdown::render("manuscript.rmd")
  md_checksum <- tail(readLines("manuscript.md"), 1)
  expect_true(md_checksum == cs_correct)

  setwd(old_wd)
})

