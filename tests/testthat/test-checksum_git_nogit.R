if(worcs:::gert_works()){
test_that("checksum is consistent if git repository is lost", {
  the_test <- "cs_git"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))
  on.exit({setwd(old_wd); unlink(test_dir, recursive = TRUE)}, add = TRUE)

  writeLines("test my checksummmm", "test.txt")
  pdf("binary_file.pdf")
  plot(rnorm(20))
  dev.off()
  # Set git stuff
  gert::git_init(path = test_dir)
  if(isFALSE(gert::user_is_configured())){
    gert::git_config_set(name = "user.name", value = "testuser", repo = ".")
    gert::git_config_set(name = "user.email", value = "c.j.vanlissa@tilburguniversity.edu", repo = ".")
  }
  gert::git_add(".")
  gert::git_commit("first commit")
  # worcs:::cs_fun("test.txt")
  # digest::digest("test.txt", file = TRUE)
  old_cs <- "ce90b657e51cfe8755ed4936f129642f"
  old_cs_binary <- digest::digest("binary_file.pdf", file = TRUE)
  expect_true(worcs:::cs_fun("test.txt") == old_cs)
  expect_true(worcs:::cs_fun("binary_file.pdf") == old_cs_binary)

  # Remove git repo
  system2("rm", "-fr .git")
  expect_true(suppressMessages(worcs:::cs_fun("test.txt")) == old_cs)
  expect_true(suppressMessages(worcs:::cs_fun("binary_file.pdf")) == old_cs_binary)
})
}

