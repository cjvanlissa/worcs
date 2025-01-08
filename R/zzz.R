#' @importFrom rlang inform
#' @importFrom cli format_inline
greet_startup <- function() {
  msg <- "Welcome to WORCS: Workflow for Open Reproducible Code in Science. Run {.code check_worcs_installation()} to make sure all dependencies are installed. For more information, see the {.href [package vignettes](https://cjvanlissa.github.io/worcs/articles)} and accompanying paper: {.href [Van Lissa and colleagues (2020)](https://doi.org/10.3233/DS-210031)}"
  rlang::inform(cli::format_inline(msg), class = "packageStartupMessage")
}

# @importFrom rstudioapi versionInfo
.onAttach <- function(libname, pkgname) {
  greet_startup()
}
