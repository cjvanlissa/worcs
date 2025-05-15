if(worcs:::gert_works()){
library(gert)
library(digest)
test_that("checksum handles different line endings", {
  the_test <- "cs_line_endings"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  worcs:::write_worcsfile(file.path(test_dir, ".worcs"))
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  txt <- c("Lorem ipsum dolor sit amet,", "consectetur adipiscing elit,", "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
  writeLines(txt, "slashn.txt", sep = "\n")
  writeLines(txt, "slashr.txt", sep = "\r")
  writeLines(txt, "slashrn.txt", sep = "\r\n")

  cs_correct <- "fabfeae70e2b9b605e5edd1e232d4b3a"

  cs_n <- worcs:::cs_fun("slashn.txt")
  cs_r <- worcs:::cs_fun("slashr.txt")
  cs_rn <- worcs:::cs_fun("slashrn.txt")

  expect_true(cs_n == cs_correct)

  expect_true(cs_r == cs_correct)

  expect_true(cs_rn == cs_correct)


# With git ----------------------------------------------------------------

  gert::git_init(path = test_dir)
  if(!gert::user_is_configured(repo = test_dir)){
    gert::git_config_set("user.name", "Jerry", repo = test_dir)
    gert::git_config_set("user.email", "jerry@gmail.com", repo = test_dir)
  }
  gert::git_add(".", repo = test_dir)
  gert::git_commit("first commit", repo = test_dir)

  cs_n <- worcs:::cs_fun("slashn.txt")
  cs_r <- worcs:::cs_fun("slashr.txt")
  cs_rn <- worcs:::cs_fun("slashrn.txt")

  expect_true(cs_n == cs_correct)

  expect_true(cs_r == cs_correct)

  expect_true(cs_rn == cs_correct)


# Compare to digest -------------------------------------------------------

  expect_true(!(cs_r == digest::digest("slashr.txt", file = TRUE)))
  expect_true(!(cs_n == digest::digest("slashn.txt", file = TRUE)))
  expect_true(!(cs_rn == digest::digest("slashrn.txt", file = TRUE)))

  setwd(old_wd)
})
}
