#' @title Export Project
#' @param filename path to a target directory or path to a zip file that is to be created
#' @param open.data boolean. Export including open data?
#' @return boolean. Success of the operation
#' @importFrom utils tail
#' @importFrom gert git_ls
#' @export
export_project <- function(filename=NULL, open.data=TRUE)
{
  # get properties about the project and paths
  # TODO: is there a robust way to get Rstudio base path?
  #  base.dir <- rstudioapi::getActiveProject()
  base.dir <- getwd()
  # List tracked files: gert::git_ls()
  project.folder <- tail(strsplit(base.dir,.Platform$file.sep)[[1]],1)

  # if no filename is given, export to a zip file with
  # the name of the project folder
  if (is.null(filename)) {
    filename=paste0("..",.Platform$file.sep,project.folder,".zip")
  }

  if (!is.character(filename)) {
    message("Filename must be of type character:",as.character(filename))
    return(FALSE)
  }

  # determine mode of operation
  zip.mode <- endsWith(filename,".zip")


  if (zip.mode) {

    if (file.exists(filename)) {
      message("Error! File exists!")
      return(FALSE)
    }
    # Use this to decide which files to ZIP, but always add data.csv
    # if the user specifies open.data = TRUE
    files <- git_ls()

    if (isFALSE(open.data)) {
      filter <- sapply(files, function(x){!endsWith(x,"data.csv")})
      if (any(filter)) {
        print("Excluding open data file.")
      }
      files <- files[filter]
    }

    utils::zip(filename, files=files, flags="-rq",)

  }
  else {

    if (file.exists(paste0(filename,.Platform$file.sep,project.folder))) {
      print("Error! Target directory exists!")
      return(FALSE)
    }

    files <- list.files(base.dir,full.names = TRUE)

    dir.create(filename, recursive=TRUE)
    file.copy(paste0(base.dir,.Platform$file.sep),
              filename,
              recursive = TRUE,
              copy.mode = TRUE,
              copy.date = TRUE)

    # remove data file
    if (isFALSE(open.data)) {

      file.remove(file.path(filename,.Platform$file.sep,project.folder,"data.csv"))
      print("Excluding open data file.")
    }
  }
}
