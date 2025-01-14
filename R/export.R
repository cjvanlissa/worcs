#' @title Export project to .zip file
#' @param zipfile Character. Path to a \code{.zip} file that is to be created.
#' The default argument \code{NULL} creates a \code{.zip} file in the directory
#' one level above the 'worcs' project directory. By default, all files tracked
#' by 'Git' are included in the \code{.zip} file, excluding 'data.csv' if
#' \code{open_data = FALSE}.
#' @param worcs_directory Character. Path to the WORCS project directory to
#' export. Defaults to \code{"."}, which refers to the current working
#' directory.
#' @param open_data Logical. Whether or not to include the original data,
#' 'data.csv', if this file exists. If \code{open_data = FALSE} and an open
#' data file does exist, then it is excluded from the \code{.zip} file. If it
#' does not yet exist, a synthetic data set is generated and added to the
#' \code{.zip} file.
#' @return Logical, indicating the success of the operation. This function is
#' called for its side effect of creating a \code{.zip} file.
#' @examples
#' export_project(worcs_directory = tempdir())
#' @importFrom utils tail zip
#' @importFrom gert git_ls
#' @export
export_project <- function(zipfile = NULL, worcs_directory = ".", open_data = TRUE)
{
  # get properties about the project and paths
  #worcs_directory <- normalizePath(worcs_directory)
  if(isFALSE(suppressWarnings(with_cli_try("Reading '.worcs' file.", {
    worcsfile <- yaml::read_yaml(file.path(worcs_directory, ".worcs"))
  })))) return(invisible(FALSE))

  zip_these <- tryCatch({
    gert::git_ls(repo = worcs_directory)$path
  }, error = function(e){
    col_message("Could not find 'Git' repository.", success = FALSE)
    FALSE
  })
  if(isFALSE(zip_these)) return(invisible(FALSE))
  project_folder <- basename(normalizePath(worcs_directory))

  # if no zipfile is given, export to a zip file with
  # the name of the project folder
  if(is.null(zipfile)) {
    zipfile <- tryCatch(file.path(dirname(normalizePath(worcs_directory)), paste0(project_folder, ".zip")), error = function(e) NULL)
  }
  if(!is.character(zipfile)){
    col_message("Could not create zipfile.", success = FALSE)
    return(invisible(FALSE))
  }

  if (file.exists(zipfile)) {
    stop("Could not write to '", zipfile, "' because the file already exists.")
    return(invisible(FALSE))
  }

  # Use this to decide which files to ZIP, but always add data.csv
  # if the user specifies open_data = TRUE
  if(!is.null(worcsfile[["data"]])){
    data_original <- names(worcsfile[["data"]])
    data_synthetic <- unlist(lapply(data_original, function(i){worcsfile[["data"]][[i]][["synthetic"]]}))
    if(!open_data){
      data_original <- vector("character")
      for(this_file in data_original){
        endsw <- endsWith(x = zip_these, suffix = this_file)
        if(any(endsw)){
          zip_these <- zip_these[-which(endsw)]
        }
      }
    }
    zip_these <- unique(c(zip_these, data_original, data_synthetic))
  }
  usethis::with_project(path = worcs_directory, code = {
    outcome <- zip(zipfile = zipfile, files = zip_these, flags="-rq")
  })
  if(!outcome == 0){
    return(invisible(FALSE))
  } else {
    return(invisible(TRUE))
  }
}
