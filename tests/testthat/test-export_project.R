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

do.call(git_signature, worcs:::get_signature)

testdir <- file.path(tempdir(), "export")
testzip <- tempfile(fileext = ".zip")
dir.create(testdir)
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

result <- export_project(zipfile = testzip, worcs_directory = testdir, open_data = FALSE)

test_that("export returned true", {
  expect_true(result)
})

test_that("exported worcs_project exists", {
  expect_true(file.exists(testzip))
})

# setwd(old_wd)
#unlink(c(file.path(testdir, "export.zip"), testdir), recursive = TRUE)
