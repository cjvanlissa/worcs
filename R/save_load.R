#' @title Save open data file
#' @description This function saves a data.frame as a .csv file, stores a
#' checksum in 'data_checksum.txt', appends the .gitignore file to exclude
#' 'data.csv', and writes a stem for 'data_cleaning.R'.
#' @param data A data.frame to save.
#' @param codebook Logical, indicating whether to render a codebook or not. If
#' set to \code{TRUE}, the default, a file called 'codebook.Rmd' is created and
#' rendered to 'codebook.md' for 'GitHub'.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' the_test <- "opendata"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' setwd(file.path(tempdir(), the_test))
#' open_data(iris[1:5, ], codebook = NULL)
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname open_data
#' @seealso closed_data
#' @export
open_data <- function(data, codebook = TRUE){
  Args <- as.list(match.call()[-1])
  Args$open <- TRUE
  Args$codebook <- codebook
  do.call(save_data, Args)
}

#' @title Save closed data file
#' @description This function saves a data.frame as a .csv file, stores a
#' checksum in 'data_checksum.txt', appends the .gitignore file to ignore
#' all '.csv' files, and writes a stem for 'data_cleaning.R'.
#' @param data A data.frame to save.
#' @param codebook Logical, indicating whether to render a codebook or not. If
#' set to \code{TRUE}, the default, a file called 'codebook.Rmd' is created and
#' rendered to 'codebook.md' for 'GitHub'.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' the_test <- "closeddata"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' setwd(file.path(tempdir(), the_test))
#' closed_data(iris[1:10, ], codebook = NULL)
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname closed_data
#' @seealso open_data
#' @export
closed_data <- function(data, codebook = TRUE){
  Args <- as.list(match.call()[-1])
  Args$open <- FALSE
  Args$codebook <- codebook
  do.call(save_data, Args)
}

#' @importFrom tools md5sum
#' @importFrom utils write.csv
save_data <- function(data, open, codebook = TRUE){
  if(!inherits(data, c("data.frame", "matrix"))){
    stop("Argument 'data' must be a data.frame, matrix, or inherit from these classes.")
  }
  if(!file.exists(".gitignore")){
    message("Could not find .gitignore file. You might not be working from the main project directory. Created .gitignore file in folder: ", getwd())
    file.create(".gitignore")
  }
  data <- as.data.frame(data)
  if(codebook){
    make_codebook(data)
  }
  message("Storing original data in 'data.csv' and updating the checksum in '.worcs'.")
  write.csv(data, "data.csv", row.names = FALSE)
  store_checksum("data.csv")
  gitig <- readLines(".gitignore")
  if(open){
    if(!any(grepl("!data.csv", gitig))){
      message('Updating ".gitignore".')
      write("!data.csv", file = ".gitignore", append = TRUE)
    }
  } else {
    if(!any(grepl("!synthetic_data.csv", gitig))){
      message('Updating ".gitignore".')
      write("!synthetic_data.csv", file = ".gitignore", append = TRUE)
    }
    message("Generating synthetic data for public use. Ensure that no identifying information is included.")
    synth <- synthetic(data, verbose = FALSE)
    message("Storing synthetic data in 'synthetic_data.csv' and updating the checksum in '.worcs'.")
    write.csv(synth$syn, "synthetic_data.csv", row.names = FALSE)
    store_checksum("synthetic_data.csv")
  }
  if(!file.exists("data_cleaning.R")){
    message('Generating "data_cleaning.R"')
    write('# Load raw data from file -------------------------------------------------\n# This function loads the original data if available,\n# and a synthetic dataset if they are not available.\n\nlibrary(worcs)\ndata <- load_data()', "data_cleaning.R")
  }
  invisible(NULL)
}

#' @title Load data file
#' @description If the original data are available, this function loads the
#' original data. If only a synthetic dataset is available, this function loads
#' the synthetic data.
#' @return A \code{data.frame} of class \code{"worcs_data"}, containing the
#' original data, if available, or a synthetic version of the data, if the
#' original data are unavailable. The \code{data.frame} has an attribute, "type",
#' indicating whether the data are synthetic or original.
#' @examples
#' the_test <- "loaddata"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' setwd(file.path(tempdir(), the_test))
#' open_data(iris[1:5, ], codebook = NULL)
#' df <- load_data()
#' df
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname load_data
#' @export
#' @importFrom tools md5sum
#' @importFrom utils read.csv
#' @importFrom yaml read_yaml
load_data <- function(){
  checkworcs(iserror = TRUE)
  #cs_file <- read.csv("checksums.csv", stringsAsFactors = FALSE)
  if(file.exists("data.csv")){
    check_sum("data.csv")
    out <- read.csv("data.csv", stringsAsFactors = TRUE)
    attr(out, "type") <- "original"
  } else {
    if(file.exists("synthetic_data.csv")){
      check_sum("synthetic_data.csv")
      out <- read.csv("synthetic_data.csv", stringsAsFactors = TRUE)
      attr(out, "type") <- "synthetic"
    } else {
      stop('No valid data file found.')
    }
  }
  class(out) <- c("worcs_data", class(out))
  out
}

#' @importFrom tools md5sum
store_checksum <- function(filename) {
  # Compute checksum on loaded data to ensure conformity
  cs <- md5sum(files = filename)
  checkworcs()
  checksums <- list(cs)
  names(checksums) <- filename
  do.call(write_worcsfile,
          list(filename = ".worcs",
               checksums = checksums,
               level = 1,
               modify = TRUE)
          )
}

load_checksum <- function(filename){
  if(file.exists(".worcs")){
    cs_file <- read_yaml(".worcs")
    if(!is.null(cs_file[["checksums"]])){
      if(!is.null(cs_file[["checksums"]][[filename]])){
        return(cs_file[["checksums"]][[filename]])
      }
    }
    stop("No checksum found for file '", filename, "'.")
  } else {
    stop("No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory.")
  }
}

#' @importFrom tools md5sum
check_sum <- function(filename){
  cs <- md5sum(files = filename)
  old_cs <- load_checksum(filename = filename)
  if(!cs == old_cs){
    stop("Checksum for file '", filename, "' did not match the checksum on record (in '.worcs'). This means that the file has changed since the checksum was stored.")
  }
}


#' @importFrom utils head
#' @export
print.worcs_data <- function(x, ...){
  if(attr(x, "type") == "synthetic"){
    cat("This is a synthetic data set. The first 6 rows are:\n\n")
  }
  if(attr(x, "type") == "original"){
    cat("This is the original data set. The first 6 rows are:\n\n")
  }
  class(x) <- class(x)[-1]
  print(head(x))
}

checkworcs <- function(iserror = FALSE){
  if (!file.exists(".worcs")) {
    if(iserror){
      stop(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory."
      , call. = FALSE)
    } else {
      message(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory."
      )
      file.create(".worcs")
    }
  }
}
