test_that("preregistration can be generated", {
  the_test <- "preregistration"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  file.create(file.path(tempdir(), the_test, ".worcs"))
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  add_preregistration(
    worcs_directory = ".",
    preregistration = "vantveer_prereg"
  )
  expect_true(file.exists(".worcs"))
  #expect_true(file.exists("manuscript/american-chemical-society.csl"))
  expect_true(file.exists("preregistration.Rmd"))
  file.remove("preregistration.Rmd")
  add_preregistration(
    worcs_directory = ".",
    preregistration = "pss"
  )
  expect_true(file.exists("preregistration.Rmd"))
  setwd(old_wd)
})
