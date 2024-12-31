if(worcs:::gert_works()){
library(gert)
test_that("worcs project can be generated", {

  the_test <- "project"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)

  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  worcs_project(
    path = "worcs_project",
    manuscript = "github_document",
    preregistration = "cos_prereg",
    add_license = "CC_BY_4.0",
    use_renv = FALSE,
    remote_repo = "bla"
  )
  # list.files(file.path(test_dir, "worcs_project"))
  expect_true(file.exists("worcs_project/.worcs"))
  expect_true(file.exists("worcs_project/LICENSE")|file.exists("worcs_project/LICENSE.md"))
  expect_true(file.exists("worcs_project/README.md"))
  readme_contents <- readLines("worcs_project/README.md", encoding = "UTF-8")
  expect_true(any(readme_contents == paste0("You can load this project in RStudio by opening the file called '", "worcs_project.Rproj", "'.")))
  expect_true(file.exists("worcs_project/preregistration.Rmd"))
  expect_true(file.exists("worcs_project/manuscript/manuscript.Rmd"))
  expect_error(git_status(repo = "worcs_project"), NA)

  setwd(old_wd)
})
}
