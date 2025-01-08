# the_test <- "export"
# old_wd <- getwd()
# dir.create(file.path(tempdir(), the_test))
# setwd(file.path(tempdir(), "citeall"))


#
# if(!Sys.info()['sysname'] == "Windows"){
#   if(Sys.getenv("R_ZIPCMD") == ""){
#     library(rtools)
#     if(devtools::find_rtools()) Sys.setenv(R_ZIPCMD= file.path(devtools:::dev_sitrep()$rtools_path, "zip"))
#   }
# }

# See if ZIP works at all
run_test <- tryCatch({
  testfile <- tempfile(fileext = ".txt")
  writeLines("test me", testfile)
  zipfile <- tempfile(fileext = ".zip")
  res <- zip(zipfile = zipfile, files = testfile, flags="-jrq")
  res == 0
}, error = function(e){FALSE})

if(run_test){
  #do.call(git_user, worcs:::get_user())

  testdir <- file.path(tempdir(), "export")
  testzip <- tempfile(fileext = ".zip")
  dir.create(testdir)
  on.exit(unlink(testdir, recursive = TRUE, force = TRUE))
  suppressWarnings(
    worcs_project(
      testdir,
      manuscript = "None",
      preregistration = "None",
      add_license = "None",
      use_renv = FALSE,
      remote_repo = "https"
    )
  )

  test_that("worcs_project created successfully", {
    expect_true(file.exists(file.path(testdir, ".worcs")))
  })

  result <- export_project(zipfile = testzip, worcs_directory = testdir, open_data = FALSE)

  test_that("export returned true", {
    expect_true(result)
  })

  test_that("exported worcs_project exists", {
    expect_true(file.exists(testzip))
  })

  # setwd(old_wd)
  #unlink(c(testzip, testdir), recursive = TRUE)

}
