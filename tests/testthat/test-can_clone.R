if(worcs:::gert_works()){
test_that("gert can clone repos", {
  the_test <- "gert_clone"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  on.exit({setwd(old_wd); unlink(test_dir, recursive = TRUE)}, add = TRUE)

  gert::git_clone("https://github.com/cjvanlissa/actions.git", path = test_dir)
  # gert::git_init(path = test_dir)
  # if(isFALSE(gert::user_is_configured())){
  #   gert::git_config_set(name = "user.name", value = "testuser", repo = ".")
  #   gert::git_config_set(name = "user.email", value = "c.j.vanlissa@tilburguniversity.edu", repo = ".")
  # }
  expect_true(file.exists("worcs_reproduce.yaml"))
})
}

