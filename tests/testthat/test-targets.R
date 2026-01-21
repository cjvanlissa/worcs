if(require(targets) & require(tarchetypes)){
  test_that("targets works with apa6", {
    skip_if_not_pandoc("2.0")

    withr::with_tempdir({
      # unlink("R", recursive = TRUE)
      worcs::worcs_project(path = ".",
                           manuscript = "github_document",
                           preregistration = "None",
                           add_license = "None",
                           use_renv = FALSE,
                           use_targets = TRUE,
                           use_git = FALSE
      )

      lnz <- readLines("_targets.R")
      lnz[grep("tarchetypes::", lnz, fixed = TRUE)] <- gsub(")", ", cue = tar_cue(mode = 'always'))", lnz[grep("tarchetypes::", lnz, fixed = TRUE)], fixed = TRUE)
      writeLines(lnz, "_targets.R")
      # It seems like it's necessary to first render individual output chunks,
      # then render the manuscript,
      # and THEN it's possible to render the manuscript using tar_make()

      tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
      # expect_true(file.exists("manuscript/manuscript.html"))
      tryCatch(rmarkdown::render("manuscript/manuscript.Rmd"), error = function(e){}, warning = function(w){})
      expect_true(file.exists("manuscript/manuscript.html"))
      if(file.exists("manuscript/manuscript.html")){
        file.remove("manuscript/manuscript.html")
      }
      cat(readLines("_targets.R"))
      print(list.files("./manuscript"))
      tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
      expect_true(file.exists("manuscript/manuscript.html"))
    })


  })

  # test_that("targets works with renv", {
  #   scoped_temporary_project()
  #   worcs::worcs_project(path = ".",
  #                        manuscript = "github_document",
  #                        preregistration = "None",
  #                        add_license = "None",
  #                        use_renv = TRUE,
  #                        use_targets = TRUE,
  #                        use_git = FALSE
  #   )
  #   tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
  #
  #   expect_true(file.exists("manuscript/manuscript.html"))
  #
  # })
  #


  test_that("targets works with target markdown", {
    skip_if_not_pandoc("2.0")
    withr::with_tempdir({
      worcs::worcs_project(path = ".",
                           manuscript = "target_markdown",
                           preregistration = "None",
                           add_license = "None",
                           use_renv = FALSE,
                           use_git = FALSE
      )

      tryCatch(rmarkdown::render("_targets.Rmd", quiet = TRUE), error = function(e){}, warning = function(w){})

      expect_true(file.exists("_targets.html"))
      if(file.exists("_targets.html")){
        file.remove("_targets.html")
      }

      tryCatch(worcs::reproduce(check_endpoints = FALSE), error = function(e){}, warning = function(w){})
      expect_true(file.exists("_targets.html"))
    })



  })
}
