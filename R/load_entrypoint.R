#' @title Load project entry points
#' @description Loads the designated project entry point into the default
#' editor, using \code{\link[utils]{file.edit}}.
#' @param worcs_directory Character, indicating the WORCS project directory to
#' which to save data. The default value \code{"."} points to the current
#' directory.
#' @param verbose Logical. Whether or not to print status messages to
#' the console. Default: TRUE
#' @param ... Additional arguments passed to \code{\link[utils]{file.edit}}.
#' @return No return value. This function is called for its side effects.
#' @examples
#' \dontrun{
#' if(requireNamespace("withr", quietly = TRUE)){
#'   withr::with_tempdir({
#'     # Prepare worcs file and dummy entry point
#'     worcs:::write_worcsfile(".worcs", entry_point = "test.txt")
#'     writeLines("Hello world", con = file("test.txt", "w"))
#'     # Demonstrate load_entrypoint()
#'     load_entrypoint()
#'   })
#' }
#' }
#' @rdname load_entrypoint
#' @importFrom utils file.edit
#' @export
load_entrypoint <- function(worcs_directory = ".", verbose = TRUE, ...){
  cl <- as.list(match.call()[-1])
  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  if(file.exists(fn_worcs)){
    worcsfile <- read_yaml(fn_worcs)
    col_message("Loading .worcs file.", verbose = verbose)
  } else {
    stop("No .worcs file found.")
  }
  if(!is.null(worcsfile[["entry_point"]])){
    for(thisfile in worcsfile[["entry_point"]]){
      tryCatch({
        thepath <- file.path(dn_worcs, thisfile)
        cl <- c(thepath, cl)
        cl[!names(cl) %in% c("title", "editor", "fileEncoding")] <- NULL
        do.call(file.edit, cl)
        col_message("Loading entry point '", thisfile, "'.", verbose = verbose)
      }, error = function(e){
        col_message("Could not load entry point '", thisfile, "'.", verbose = verbose, success = FALSE)
      })
    }
  } else {
    stop("No .worcs file found.")
  }
}
