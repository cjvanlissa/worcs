
#' title Export Project
#' @param filename path to a directory or a file
#' @param open.data boolean. include open data?
#' @return boolean. Success of export operation.
#' @export
export_project <- function(filename, open.data=TRUE){

  if (!is.character(filename)) {
    print("Filename must be of type character.")
    invisible(FALSE)
  } 
  
  # TODO: is there a robust way to get Rstudio base path?
  base.dir <- getwd()
  project.folder <- tail(strsplit(base.dir,.Platform$file.sep)[[1]],1)
  zip.mode <- endsWith(filename,".zip")

  browser()

  
  if (zip.mode) {
    
    if (file.exists(filename)) {
      print("Error! File exists!")
      invisible(FALSE)
    }
    
    files <- list.files(getwd(),full.names = FALSE)
    
    if (isFALSE(open.data)) {
      filter <- sapply(files, function(x){!endsWith(x,"data.csv")})
      if (any(filter)) {
        print("Excluding open data file.")
      }
      files <- files[filter]
    }
    
    utils::zip(filename, files=files, flags="-rq",)
    
  } else {
    
    if (file.exists(paste0(filename,.Platform$file.sep,project.folder))) {
      print("Error! Target directory exists!")
      invisible(FALSE)
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
  
  invisible(TRUE)
}