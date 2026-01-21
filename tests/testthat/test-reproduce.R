test_that("add_recipe is evaluated by reproduce()", {
  the_test <- "reproduce"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))
  on.exit({setwd(old_wd); unlink(test_dir, recursive = TRUE)}, add = TRUE)

  add_recipe(recipe = 'writeLines("test", "test.txt")')
  reproduce(check_endpoints = FALSE)
  expect_true(file.exists("test.txt"))
  file.remove(file.path(test_dir, ".worcs"))
  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))

  add_recipe(recipe = 'Rscript -e """writeLines("test", "test.txt")"""', terminal = TRUE)
  reproduce(check_endpoints = FALSE)
  expect_true(file.exists("test.txt"))

})


