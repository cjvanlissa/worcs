# the_test <- "export"
# old_wd <- getwd()
# dir.create(file.path(tempdir(), the_test))
# setwd(file.path(tempdir(), "citeall"))

get_sig <- tryCatch(git_signature_default(), error = function(e){
  gert::git_config_global_set(name = "user.name", value = "yourname")
  gert::git_config_global_set(name = "user.email", value = "yourname@email.com")
})

if(!Sys.info()['sysname'] == "Windows"){
  if(Sys.getenv("R_ZIPCMD") == ""){
    library(rtools)
    if(devtools::find_rtools()) Sys.setenv(R_ZIPCMD= file.path(devtools:::dev_sitrep()$rtools_path, "zip"))
  }
}

suppressWarnings(
  worcs_project("export_test",
                manuscript = "None",
                preregistration = "None",
                add_license = "None",
                use_renv = FALSE,
                remote_repo = "https")
                )
old_wd <- getwd()
setwd("export_test")
result <- export_project(open_data = FALSE)
setwd(old_wd)

test_that("correctly exported worcs_project", {
  expect_true(result)
  expect_true("export_test.zip" %in% list.files("../"))
})

# setwd(old_wd)
# unlink(file.path(tempdir(), the_test))
