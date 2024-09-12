test_that("targets works with apa6", {
  the_test <- "targets"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  on.exit({unlink(test_dir, recursive = TRUE); setwd(old_wd)}, add = TRUE)

  worcs::worcs_project(path = test_dir,
                       manuscript = "APA6",
                       preregistration = "None",
                       add_license = "None",
                       use_renv = FALSE,
                       use_targets = TRUE
                       )
  tryCatch(targets::tar_make(), error = function(e){})
  rmarkdown::render("manuscript/manuscript.rmd")
  file.remove("manuscript/manuscript.pdf")
  targets::tar_make()
  expect_true(file.exists("manuscript/manuscript.pdf"))
  setwd(old_wd)
})

test_that("targets works with renv", {
  the_test <- "targets_renv"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  on.exit({unlink(test_dir, recursive = TRUE); setwd(old_wd)}, add = TRUE)

  worcs::worcs_project(path = test_dir,
                       manuscript = "acm_article",
                       preregistration = "None",
                       add_license = "None",
                       use_renv = TRUE,
                       use_targets = TRUE
  )
  tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
  rmarkdown::render("manuscript/manuscript.rmd")
  expect_true(file.exists("manuscript/manuscript.pdf"))
  setwd(old_wd)
})



test_that("targets works with target markdown", {
  the_test <- "target_markdown"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  on.exit({unlink(test_dir, recursive = TRUE); setwd(old_wd)}, add = TRUE)

  worcs::worcs_project(path = test_dir,
                       manuscript = "target_markdown",
                       preregistration = "None",
                       add_license = "None",
                       use_renv = FALSE
  )
  rmarkdown::render("_targets.rmd")
  expect_true(file.exists("_targets.html"))
  file.remove("_targets.html")
  worcs::reproduce()
  expect_true(file.exists("_targets.html"))

  setwd(old_wd)
})
