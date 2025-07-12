# @title Set up GitHub Action to Render Manuscript
# @description Sets up a GitHub Action to render the manuscript for a WORCS
# project.
# @param worcs_directory Character, indicating the WORCS project directory
# to which to save data. The default value "." points to the current directory.
# Default: '.'
# @return No return value. This function is called for its side effects.
# @seealso
#  \code{\link[usethis]{use_github_action}}
#  \code{\link[worcs]{add_endpoint}}
#  \code{\link[worcs]{check_endpoints}}
# @export
# @importFrom usethis use_github_action
# github_action_check_endpoints <- function(worcs_directory = "."){
#   github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_endpoints.yaml")
# }


#' @title Set up GitHub Actions to Check Endpoints
#' @description Sets up a GitHub Action to perform continuous integration (CI)
#' for a WORCS project. CI automatically evaluates `check_endpoints()` or
#' `reproduce(check_endpoints = TRUE)`.
#' at each push or pull request.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @return No return value. This function is called for its side effects.
#' @seealso
#'  \code{\link[usethis]{use_github_action}}
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{check_endpoints}}
#' @export
#' @importFrom usethis use_github_action
github_action_check_endpoints <- function(worcs_directory = "."){
  github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_endpoints.yaml")
}


#' @rdname github_action_check_endpoints
#' @export
#' @importFrom usethis use_github_action
github_action_reproduce <- function(worcs_directory = "."){
  # Check if all data sources will be available on GitHub
  has_data <- check_data_resources(dn_worcs = worcs_directory,
                                   worcsfile = NULL,
                                   verbose = TRUE)
  gitig <- readLines(file.path(worcs_directory, ".gitignore"))
  if(any(has_data$data_files %in% gitig)){
    col_message(paste0("The following original data sources are not available on GitHub, which could prevent the GitHub action from reproducing your analysis:\n", paste0(has_data$data_files[which(has_data$data_files %in% gitig)], collapse = ", ")), success = FALSE)
  }
  github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_reproduce.yaml")
}


#' @rdname github_action_check_endpoints
#' @export
#' @importFrom usethis use_github_action
github_action_testthat <- function(worcs_directory = "."){
  github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_testthat.yaml")
}

github_action_generic <- function(worcs_directory = ".", url = NULL){
  Args <- list(
    url = url
  )
  if(!normalizePath(getwd()) == normalizePath(worcs_directory)){
    usethis::ui_info("The current directory is not the same as 'worcs_directory'. The GitHub action might not install correctly.")
  }

  if("badge" %in% names(formals(usethis::use_github_action))){
    Args$badge <- TRUE
    if(file.exists(file.path(worcs_directory, "README.md"))){
      Args$readme <- file.path(worcs_directory, "README.md")
    }
  } else {
    usethis::ui_oops("Could not add badge to readme.md; consider updating the 'usethis' package by running install.packages('usethis').")
  }
  do.call(usethis::use_github_action, Args)
}

github_action_check_endpoints <- function(worcs_directory = "."){
  github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_endpoints.yaml")
}


github_action_render <- function(worcs_directory = "."){
  github_action_generic(worcs_directory = worcs_directory, url = "https://github.com/cjvanlissa/actions/blob/main/worcs_endpoints.yaml")
}
