#' @title Export project to .zip file
#' @param filename Character. Path to a \code{.zip} file that is to be created.
#' The default argument \code{NULL} creates a \code{.zip} file in the directory
#' one level above the 'worcs' project directory. By default, all files tracked
#' by 'Git' are included in the \code{.zip} file, excluding 'data.csv' if
#' \code{open_data = FALSE}.
#' @param open_data Logical. Whether or not to include the original data,
#' 'data.csv', if this file exists. If \code{open_data = FALSE} and an open
#' data file does exist, then it is excluded from the \code{.zip} file. If it
#' does not yet exist, a synthetic data set is generated and added to the
#' \code{.zip} file.
#' @return Logical, indicating the success of the operation. This function is
#' called for its side effect of creating a \code{.zip} file.
#' @examples
#' export_project()
#' @importFrom utils tail zip
#' @importFrom gert git_ls
#' @export
export_project <- function(filename = NULL, open_data = TRUE)
{
  # get properties about the project and paths
  base_dir <- normalizePath(".")
  if(!file.exists(".worcs")){
    col_message("No '.worcs' file found; not a WORCS project, or the working directory has been changed.", success = FALSE)
    return(invisible(FALSE))
  }
  project_folder <- gsub("^.+\\b(.+?)$", "\\1", base_dir)

  # if no filename is given, export to a zip file with
  # the name of the project folder
  if (is.null(filename)) {
    filename <- file.path("..", paste0(project_folder, ".zip"))
  }

  if (!is.character(filename)) {
    col_message(paste0("Filename must be of type character: ",as.character(filename)), success = FALSE)
    return(invisible(FALSE))
  }


    if (file.exists(filename)) {
      stop("Could not write to '", filename, "' because the file already exists.")
      return(invisible(FALSE))
    }
    # Use this to decide which files to ZIP, but always add data.csv
    # if the user specifies open_data = TRUE
    zip_these <- git_ls()$path
    tmpfile <- NULL
    if (isFALSE(open_data)) {
      hasdata <- endsWith(zip_these, "data.csv")
      if (any(hasdata)) {
        col_message("Excluding open data file and generating synthetic data for archive. Ensure that no identifying information is included.")
        zip_these <- zip_these[!hasdata]
        if(!any(zip_these == "synthetic_data.csv")){
          data <- read.csv(zip_these[endsWith(zip_these, "data.csv")], stringsAsFactors = TRUE)
          synth <- synthetic(data, verbose = FALSE)
          tmpfile <- file.path(tempdir(), "synthetic_data.csv")
          write.csv(synth$syn, tmpfile, row.names = FALSE)
          zip_these <- c(zip_these, tmpfile)
        }
      }
    }
    outcome <- zip(filename, files = zip_these, flags="-rq")
    if(!is.null(tmpfile)){
      invisible(file.remove(tmpfile))
    }
    if(!outcome == 0){
      return(invisible(FALSE))
    } else {
      return(invisible(TRUE))
    }
}
