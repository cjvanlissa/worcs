#' @title Export Project
#' @param filename path to a target directory or path to a zip file that is to be created
#' @param open.data boolean. Export including open data?
#' @return boolean. Success of the operation
#' @importFrom utils tail
#' @export
export_project <- function(filename, open.data=TRUE)
{
  
  if (!is.character(filename)) {
    print("Filename must be of type character.")
    return(FALSE)
  } 
  
  # TODO: is there a robust way to get Rstudio base path?
#  base.dir <- rstudioapi::getActiveProject()
  base.dir <- getwd()
  project.folder <- tail(strsplit(base.dir,.Platform$file.sep)[[1]],1)
  zip.mode <- endsWith(filename,".zip")
  
  if (zip.mode) {
    
    if (file.exists(filename)) {
      print("Error! File exists!")
      return(FALSE)
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
