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
  test_that("worcs_project can be exported via ZIP", {
    scoped_temporary_project()
    testdir <- file.path(tempdir(), "zip")
    dir.create(testdir)
    oldwd <- getwd()
    setwd(testdir)

    testdir <- file.path(".")
    testzip <- "test.zip"

  suppressWarnings(
    worcs_project(
      ".",
      manuscript = "None",
      preregistration = "None",
      add_license = "None",
      use_renv = FALSE,
      remote_repo = NULL
    )
  )


    expect_true(file.exists(".worcs"))

    result <- export_project(zipfile = testzip, worcs_directory = ".", open_data = FALSE)


    expect_true(result)

    expect_true(file.exists(testzip))
})

  # setwd(old_wd)
  #unlink(c(testzip, testdir), recursive = TRUE)

}
