library(targets)
test_that("targets works with apa6", {
  scoped_temporary_project()

  worcs::worcs_project(path = ".",
                       manuscript = "github_document",
                       preregistration = "None",
                       add_license = "None",
                       use_renv = FALSE,
                       use_targets = TRUE,
                       use_git = FALSE
                       )
  # It seems like it's necessary to first render individual output chunks,
  # then render the manuscript,
  # and THEN it's possible to render the manuscript using tar_make()
  tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
  tryCatch(rmarkdown::render("manuscript/manuscript.rmd"), error = function(e){}, warning = function(w){})
  file.remove("manuscript/manuscript.html")
  tryCatch(targets::tar_make(), error = function(e){}, warning = function(w){})
  expect_true(file.exists("manuscript/manuscript.html"))

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
  scoped_temporary_project()

  worcs::worcs_project(path = ".",
                       manuscript = "target_markdown",
                       preregistration = "None",
                       add_license = "None",
                       use_renv = FALSE,
                       use_git = FALSE
  )
  # file.remove(file.path(test_dir, "_targets.rmd"))
  if(file.exists("_targets.r")){
    file.remove("_targets.r")
  }
  linz <- c("---", "  title: \"Target Markdown\"", "  output: html_document",
            "---", "", "```{r setup, include = FALSE}", "knitr::opts_chunk$set(collapse = TRUE, comment = \"#>\")",
            "```", "", "# Setup", "", "bla", "", "```{r}", "library(targets)",
            "tar_unscript()", "```", "", "# Targets", "", "bla", "", "```{targets raw-data}",
            "tar_target(raw_data, airquality)", "```", "", "blbaal", "",
            "```{targets downstream-targets}", "list(", "  tar_target(data, {raw_data[complete.cases(airquality), ]}),",
            "  tar_target(hist, hist(data$Ozone))", ")", "```", "", "try this now",
            "", "```{targets fit, tar_simple = TRUE}", "lm(Ozone ~ Wind + Temp, data)",
            "```", "", "# Pipeline", "", "run everything", "", "```{r}",
            "tar_make()", "```", "", "# Output", "", "get results", "", "```{r, message = FALSE}",
            "tar_read(fit)", "```", "", "```{r}", "tar_read(hist)", "```",
            "", "", "interactive")

  cat(linz, file = "_targets.rmd", append = FALSE, sep = "\n")

  tryCatch(rmarkdown::render("_targets.rmd"), error = function(e){}, warning = function(w){})

  expect_true(file.exists("_targets.html"))
  if(file.exists("_targets.html")){
    file.remove("_targets.html")
  }

  tryCatch(worcs::reproduce(check_endpoints = FALSE), error = function(e){}, warning = function(w){})
  expect_true(file.exists("_targets.html"))


})

