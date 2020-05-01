
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
  
  if (file.exists(filename)) {
    print("Error! File exists!")
    invisible(FALSE)
  }
  
  
  
  if (endsWith(filename,".zip")) {
    files <- list.files(getwd(),full.names = TRUE)
    
    if (isFALSE(open.data)) {
      filter <- sapply(files, function(x){!endsWith(x,"data.csv")})
      if (any(filter)) {
        print("Excluding open data file.")
      }
      files <- files[filter]
    }
    
    utils::zip(filename, files=files, flags="-r")
  } else {
    if (!file.exists(filename)) {
      dir.create(filename, recursive=TRUE)
    }
  }
  
  invisible(TRUE)
}