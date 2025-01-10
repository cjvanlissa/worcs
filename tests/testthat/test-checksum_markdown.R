test_that("checksum works from within Rmarkdown", {

  skip_if_not_pandoc("2.0")
  scoped_temporary_project()
  test_dir = "."
  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))
  dat <- iris[1:4,1:4]
  open_data(dat)
  cs_correct <- read_yaml(".worcs")$checksums[["dat.csv"]]

  expect_true(worcs:::cs_fun(filename = file.path(test_dir, "dat.csv"), worcsfile = file.path(test_dir, ".worcs")) == cs_correct)

  dir.create(file.path(test_dir, "manuscript"))
  setwd(file.path(test_dir, "manuscript"))

  # expect_true(worcs:::cs_fun(filename = file.path(test_dir, "dat.csv"), worcsfile = file.path(test_dir, ".worcs")) == cs_correct)
  #
  man_txt <- c("---", "title: \"Untitled\"", "output: github_document", "---",
               "", "```{r setup}", "library(\"worcs\")", "load_data()", "```", "", "`r worcs:::cs_fun(file.path(dirname(worcs:::check_recursive(file.path(normalizePath('.')))), 'dat.csv'), file.path(dirname(worcs:::check_recursive(file.path(normalizePath('.')))), '.worcs'))`")
  writeLines(man_txt, "manuscript.Rmd")
  rmarkdown::render("manuscript.Rmd")
  md_checksum <- tail(readLines("manuscript.md"), 1)
  expect_true(md_checksum == cs_correct)

})

