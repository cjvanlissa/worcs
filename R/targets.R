#' @title Add targets to WORCS Project
#' @description Add a computational pipeline to a `worcs` project using the
#' `targets` and `tarchetypes` packages (which must be installed). See those
#' packages for extensive documentation.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: `TRUE`
#' @param ... Arguments passed to `targets::use_targets()`.
#' @return No return value. This function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "targets")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' add_targets()
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname add_targets
#' @export
add_targets <- function (worcs_directory = ".", verbose = TRUE, ...){
  checkworcs(worcs_directory, iserror = TRUE)
  fn_worcs <- path_abs_worcs(".worcs", worcs_directory)
  if (!file.exists(fn_worcs)) {
    stop(".worcs file not found.")
  }
  if(!(requireNamespace("targets", quietly = TRUE) & requireNamespace("tarchetypes", quietly = TRUE))) {
    c(requireNamespace("targets", quietly = TRUE) & requireNamespace("tarchetypes", quietly = TRUE))
    worcs:::col_message("Could not find required packages; please run ",

                        paste0(c(c("install.packages('targets')", "")[requireNamespace("targets", quietly = TRUE)+1L], c("install.packages('tarchetypes')", "")[requireNamespace("tarchetypes", quietly = TRUE)+1L]), collapse = "; "),
                        " then try again."
                        , success = FALSE
    )
    return(invisible(FALSE))
  } else {

    worcs_file <- yaml::read_yaml(fn_worcs)
    tryCatch({
      targets::use_targets(...)
      col_message("Added targets to project.")
    }, error = function(e){col_message("Could not add targets to project.", success = FALSE)})
    to_worcs <- list(filename = fn_worcs, modify = TRUE)
    if(file.exists(worcs:::path_abs_worcs("run.r", worcs_directory = worcs_directory))){
      col_message("Setting entry point to 'run.r'.", verbose = verbose)
      to_worcs$entry_point <- "run.r"
      to_worcs$recipe <- list(recipe = "source('run.r')", terminal = FALSE)
      col_message("Setting recipe to source('run.r').", verbose = verbose)
    } else {
      to_worcs$recipe <- list(recipe = "targets::tar_make()", terminal = FALSE)
      col_message("Setting recipe to targets::tar_make().", verbose = verbose)
    }
    if(file.exists(worcs:::path_abs_worcs("manuscript/manuscript.rmd", worcs_directory = worcs_directory)) & file.exists(worcs:::path_abs_worcs("_targets.R", worcs_directory = worcs_directory))){
      lnz <- readLines(worcs:::path_abs_worcs("_targets.R", worcs_directory = worcs_directory))
      if(all(tail(lnz, 2) == c("  )", ")"))){
        col_message("Adding rmarkdown manuscript to targets pipeline.", verbose = verbose)
        lnz <- c(lnz[1:(length(lnz)-3)],
                 c("  ),", "  tarchetypes::tar_render(manuscript, \"manuscript/manuscript.rmd\")",
                   ")"))
        writeLines(text = lnz, con = worcs:::path_abs_worcs("_targets.R", worcs_directory = worcs_directory))
      } else {
        col_message("Could not add rmarkdown manuscript to targets pipeline.", verbose = verbose, success = FALSE)
      }
    }
    do.call(write_worcsfile, to_worcs)
  }
  return(invisible(TRUE))
}
