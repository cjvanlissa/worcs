get_sig <- tryCatch(git_signature_default(), error = function(e){
  gert::git_config_global_set(name = "user.name", value = "yourname")
  gert::git_config_global_set(name = "user.email", value = "yourname@email.com")
})
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

test_that("can append one nested yaml key/value", {
  expect_true(result)
})

