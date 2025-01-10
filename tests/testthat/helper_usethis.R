skip_if_not_pandoc <- function(ver = NULL) {
  if (!pandoc_available(ver)) {
    msg <- if (is.null(ver)) {
      "Pandoc is not available"
    } else {
      sprintf("Version of Pandoc is lower than %s.", ver)
    }
    skip(msg)
  }
}

# copied from usethis:
# https://github.com/r-lib/usethis/blob/b2e894eb6d1d7f3312a783db3bb03a7cc309ba61/tests/testthat/helper.R
library(usethis)
library(fs)

## attempt to activate a project, which is nice during development
tryCatch(usethis::proj_set("."), error = function(e) NULL)

## If session temp directory appears to be, or be within, a project, there
## will be large scale, spurious test failures.
## The IDE sometimes leaves .Rproj files behind in session temp directory or
## one of its parents.
## Delete such files manually.
session_temp_proj <- usethis:::proj_find(path_temp())
if (!is.null(session_temp_proj)) {
  Rproj_files <- fs::dir_ls(session_temp_proj, glob = "*.Rproj")
  ui_line(c(
    "Rproj file(s) found at or above session temp dir:",
    paste0("* ", Rproj_files),
    "Expect this to cause spurious test failures."
  ))
}

## putting `pattern` in the package or project name is part of our strategy for
## suspending the nested project check during testing
pattern <- "aaa"

scoped_temporary_package <- function(dir = fs::file_temp(pattern = pattern),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "package")
}

scoped_temporary_project <- function(dir = fs::file_temp(pattern = pattern),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "project")
}

scoped_temporary_thing <- function(dir = fs::file_temp(pattern = pattern),
                                   env = parent.frame(),
                                   rstudio = FALSE,
                                   thing = c("package", "project")) {
  thing <- match.arg(thing)
  if (fs::dir_exists(dir)) {
    stop("Target dir already exists.")
  }

  old_project <- usethis:::proj_get_()
  old_wd <- getwd()          # not necessarily same as `old_project`

  withr::defer(
    {
      fs::dir_delete(dir)
    },
    envir = env
  )
  usethis::ui_silence(
    usethis::create_project(dir, rstudio = rstudio, open = FALSE)

  )

  withr::defer(usethis::proj_set(old_project, force = TRUE), envir = env)
  usethis::proj_set(dir)

  withr::defer(
    {
      setwd(old_wd)
    },
    envir = env
  )
  setwd(usethis::proj_get())

  invisible(usethis::proj_get())
}

test_mode <- function() {
  before <- Sys.getenv("TESTTHAT")
  after <- if (before == "true") "false" else "true"
  Sys.setenv(TESTTHAT = after)
  cat("TESTTHAT:", before, "-->", after, "\n")
  invisible()
}

skip_if_not_ci <- function() {
  ci <- any(toupper(Sys.getenv(c("TRAVIS", "APPVEYOR"))) == "TRUE")
  if (ci) {
    return(invisible(TRUE))
  }
  skip("Not on Travis or Appveyor")
}

expect_usethis_error <- function(...) {
  expect_error(..., class = "usethis_error")
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

is_build_ignored <- function(pattern, ..., base_path = proj_get()) {
  lines <- readLines(path(base_path, ".Rbuildignore"), warn = FALSE)
  length(grep(pattern, x = lines, fixed = TRUE, ...)) > 0
}

test_file <- function(fname) testthat::test_path("ref", fname)

expect_proj_file <- function(...) expect_true(fs::file_exists(usethis::proj_path(...)))
expect_proj_dir <- function(...) expect_true(fs::dir_exists(usethis::proj_path(...)))

## use from testthat once > 2.0.0 is on CRAN
skip_if_offline <- function(host = "r-project.org") {
  skip_if_not_installed("curl")
  has_internet <- !is.null(curl::nslookup(host, error = FALSE))
  if (!has_internet) {
    skip("offline")
  }
}
