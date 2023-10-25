#' @title Add Recipe to Generate Endpoints
#' @description Add a recipe to a WORCS project file to generate its endpoints.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param recipe Character string, indicating the function call to evaluate in
#' order to reproduce the endpoints of the WORCS project.
#' @param terminal Logical, indicating whether or not to evaluate the `recipe`
#' in the terminal (`TRUE`) or in R (`FALSE`). Defaults to `FALSE`
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: `TRUE`
#' @param ... Additional arguments.
#' @return No return value. This function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "add_recipe")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' writeLines("test", "test.txt")
#' add_recipe()
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname add_recipe
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{snapshot_endpoints}}
#'  \code{\link[worcs]{check_endpoints}}
#' @export
add_recipe <- function(worcs_directory = ".", recipe = "rmarkdown::render('manuscript/manuscript.Rmd')", terminal = FALSE, verbose = TRUE, ...){
  checkworcs(worcs_directory, iserror = TRUE)
  fn_worcs <- path_abs_worcs(".worcs", worcs_directory)
  if(!file.exists(fn_worcs)){
    stop(".worcs file not found.")
  }
  worcs_file <- read_yaml(fn_worcs)
  # if(is.null(worcs_file[["entry_point"]])){
  #   col_message("This WORCS project does not contain an entry point. Make sure that it .", success = FALSE, verbose = verbose)
  # }

  # Prepare for writing to worcs file
  to_worcs <- list(
    filename = fn_worcs,
    modify = TRUE
  )

  # Synthetic data
  col_message("Adding recipe to '.worcs'.", verbose = verbose)

  to_worcs$recipe <- list(recipe = recipe,
                          terminal = terminal)

  do.call(write_worcsfile, to_worcs)

}


#' @title Reproduce WORCS Project
#' @description Evaluate the recipe contained in a WORCS project to derive its
#' endpoints.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: `TRUE`
#' @param check_endpoints Logical. Whether or not to call `check_endpoints()`
#' after reproducing the recipe. Default: `TRUE`
#' @param ... Additional arguments.
#' @return No return value. This function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "reproduce")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' worcs:::add_recipe(recipe = 'writeLines("test", "test.txt")')
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname reproduce
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{snapshot_endpoints}}
#'  \code{\link[worcs]{check_endpoints}}
#' @export
reproduce <- function(worcs_directory = ".", verbose = TRUE, check_endpoints = TRUE, ...){
  checkworcs(worcs_directory, iserror = TRUE)
  fn_worcs <- path_abs_worcs(".worcs", worcs_directory)
  if(!file.exists(fn_worcs)){
    stop(".worcs file not found.")
  }
  worcs_file <- read_yaml(fn_worcs)

  if(is.null(worcs_file[["recipe"]])){
    # Check if it's an old worcs version that does have an entry point
    if(!is.null(worcs_file[["entry_point"]])){
      col_message("No recipe found in WORCS project. Attempting to deduce recipe from entry_point.", verbose = verbose, success = FALSE)

      if(grepl(".rmd", tolower(worcs_file[["entry_point"]]), fixed = TRUE)){
        worcs_file[["recipe"]] <- list(recipe = paste0("rmarkdown::render('", worcs_file[["entry_point"]],"')"), terminal = FALSE)
      }
      if(grepl(".r", tolower(worcs_file[["entry_point"]]), fixed = TRUE)){
        worcs_file[["recipe"]] <- list(recipe = paste0("source('", worcs_file[["entry_point"]], "')"), terminal = FALSE)
      }
    } else {
      stop("No recipe or entry_point found in '.worcs' file.")
    }
  }

  out <- if(isTRUE(worcs_file[["recipe"]][["terminal"]])){
    try(do.call(system, list(command = worcs_file[["recipe"]][["recipe"]])))
  } else {
    try(eval.parent(parse(text = worcs_file[["recipe"]][["recipe"]])))
  }

  if(inherits(out, "try-error")){
      if(interactive()){
        col_message("Attempt to run recipe to reproduce this WORCS project failed.", verbose = verbose, success = FALSE)
        return()
      } else {
        stop("Attempt to run recipe to reproduce this WORCS project failed.")
      }
  }

  if(check_endpoints){
    check_endpoints(worcs_directory = dirname(fn_worcs), verbose = verbose)
  }

}
