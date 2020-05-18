#' @title Use open data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils]{write.csv}}), stores a checksum in '.worcs',
#' and amends the \code{.gitignore} file to exclude \code{filename}.
#' @param data A data.frame to save.
#' @param filename Character, naming the file data should be written to.
#' @param codebook Character, naming the file the codebook should be written to.
#' An 'R Markdown' codebook will be created and rendered to
#' \code{\link[rmarkdown]{github_document}} ('markdown' for 'GitHub').
#' Defaults to 'codebook.Rmd'. Set to \code{NULL} to avoid creating a codebook.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' test_dir <- file.path(tempdir(), "data")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' open_data(iris[1:5, ], codebook = "bla.Rmd")
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname open_data
open_data <- function(data, filename = "data.csv", codebook = "codebook.Rmd"){
  Args <- as.list(match.call()[-1])
  Args$open <- TRUE
  do.call(save_data, Args)
}

#' @title Use closed data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils]{write.csv}}), stores a checksum in '.worcs',
#' appends the \code{.gitignore} file to exclude \code{filename}, and saves a
#' synthetic copy of \code{data} for public use. To generate these synthetic
#' data, the function \code{\link{synthetic}} is used.
#' @inheritParams open_data
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' test_dir <- file.path(tempdir(), "data")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' closed_data(iris[1:10, ], codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname closed_data
closed_data <- function(data,
                        filename = "data.csv",
                        codebook = "codebook.Rmd"){
  Args <- as.list(match.call()[-1])
  Args$open <- FALSE
  do.call(save_data, Args)
}

#' @importFrom digest digest
#' @importFrom utils write.csv
save_data <- function(data,
                      filename = "data.csv",
                      open,
                      codebook = "codebook.Rmd"){
  cl <- as.list(match.call()[-1])
  synthetic_filename = paste0("synthetic_", filename)
  to_worcs <- list(
    filename = ".worcs",
    modify = TRUE
  )
  if(!inherits(data, c("data.frame", "matrix"))){
    stop("Argument 'data' must be a data.frame, matrix, or inherit from these classes.")
  }

# Store data --------------------------------------------------------------
  data <- as.data.frame(data)
  col_message("Storing original data in '", filename, "' and updating the checksum in '.worcs'.")
  write.csv(data, filename, row.names = FALSE)
  to_worcs$data[[filename]] <- vector(mode = "list")
  store_checksum(filename)

  np_filename <- suppressWarnings(normalizePath(filename))
  if(open){
    write_gitig(file.path(dirname(np_filename), ".gitignore"), paste0("!", basename(filename)))
  } else {
    # Synthetic data
    col_message("Generating synthetic data for public use. Ensure that no identifying information is included.")
    synth <- synthetic(data, verbose = FALSE)
    col_message("Storing synthetic data in '", synthetic_filename, "' and updating the checksum in '.worcs'.")
    write.csv(synth, synthetic_filename, row.names = FALSE)
    to_worcs$data[[filename]]$synthetic <- synthetic_filename
    store_checksum("synthetic_data.csv")
    np_synthetic_filename <- suppressWarnings(normalizePath(synthetic_filename))
    write_gitig(file.path(dirname(np_filename), ".gitignore"), basename(filename))
    write_gitig(file.path(dirname(np_synthetic_filename), ".gitignore"), paste0("!", basename(synthetic_filename)))
  }
  col_message("Updating '.gitignore'.")

# codebook ----------------------------------------------------------------
  if(!is.null(codebook)){
    Args_cb <- cl[which(names(cl) %in% c("data", "codebook"))]
    names(Args_cb)[which(names(Args_cb) == "codebook")] <- "filename"
    do.call(make_codebook, Args_cb)
    # Add to gitignore
    write_gitig(file.path(dirname(codebook), ".gitignore"), paste0("!", gsub(".md$", "csv", basename(codebook))))
    to_worcs$data[[filename]]$codebook <- codebook
  }
  do.call(write_worcsfile, to_worcs)
  invisible(NULL)
}

#' @title Load WORCS project data
#' @description Scans the WORCS project file for data that have been saved using
#' \code{\link{open_data}} or \code{\link{closed_data}}, and loads these data
#' into the global (working) environment. The function will load the original
#' data if available on the current system. If only a synthetic dataset is
#' available, this function loads the synthetic data.
#' The name of the object containing the data is derived from the file name by
#' removing the file extension, and, when applicable, the prefix
#' \code{"synthetic_"}. Thus, both \code{"data.csv"} and
#' \code{"synthetic_data.csv"} will be loaded into an object called \code{data}.
#' @param worcs_directory Character, indicating the WORCS project directory from
#' which to load data. The default value \code{"."} points to the current
#' directory.
#' @param to_envir Logical, indicating whether to load objects directly into
#' the environment, or return a \code{\link{list}} containing the objects. The
#' environment is designated by argument \code{envir}. Loading
#' objects directly into the global environment is user-friendly, but has the
#' risk of overwriting an existing object with the same name, as explained in
#' \code{\link{load}}. The function \code{load_data} gives a warning when this
#' happens.
#' @param envir The environment where the data should be loaded. The default
#' value \code{parent.frame(1)} refers to the global environment in an
#' interactive session.
#' @return Returns a list invisibly. If \code{to_envir = TRUE}, this list
#' contains the loaded data files. If \code{to_envir = FALSE}, the list is
#' empty, and the loaded data files are attached directly to the global
#' environment.
#' @examples
#' test_dir <- file.path(tempdir(), "loaddata")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' suppressWarnings(closed_data(iris[1:5, ], codebook = NULL))
#' load_data()
#' data
#' rm("data")
#' file.remove("data.csv")
#' load_data()
#' data
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname load_data
#' @export
#' @importFrom digest digest
#' @importFrom utils read.csv
#' @importFrom yaml read_yaml
load_data <- function(worcs_directory = ".", to_envir = TRUE, envir = parent.frame(1)){
  checkworcs(dirname(worcs_directory), iserror = TRUE)
  worcsfile <- read_yaml(file.path(worcs_directory, ".worcs"))
  if(is.null(worcsfile[["data"]])){
    stop("No data found in '.worcs'.")
  }
  data <- worcsfile$data
  data_files <- names(data)
  data_original <- sapply(data_files, function(i){file.exists(file.path(worcs_directory, i))})
  if(any(!data_original)){
    data_files[!data_original] <- sapply(data_files[!data_original], function(i){ worcsfile$data[[i]][["synthetic"]] })
  }
  data_files <- data_files[!(is.null(data_files)|is.na(data_files))]
  data_original <- data_original[!(is.null(data_files)|is.na(data_files))]
  if(length(data_files) == 0) stop("No valid data files found.")
  outlist <- vector(mode = "list")
  for(file_num in seq_along(data_files)){
    this_file <- data_files[file_num]
    check_sum(this_file)
    col_message("Loading ", c("synthetic", "original")[data_original[file_num]+1], " data from '", this_file, "'.")
    object_name <- sub('^(synthetic_)?(.+)\\..*$', '\\2', basename(this_file))
    out <- read.csv(this_file, stringsAsFactors = TRUE)
    attr(out, "type") <- c("synthetic", "original")[data_original[file_num]+1]
    class(out) <- c("worcs_data", class(out))
    if(to_envir){
      if(object_name %in% objects(envir = envir)) warning("Object '", object_name, "' already exists in the environment designated by 'envir', and will be replaced with the contents of '", this_file, "'.")
      assign(object_name, out, envir = envir)
    } else {
      outlist[[object_name]] <- out
    }
  }
  return(invisible(outlist))
}

#' @importFrom digest digest
store_checksum <- function(filename) {
  # Compute checksum on loaded data to ensure conformity
  cs <- digest(object = filename, file = TRUE)
  checkworcs(dirname(filename), iserror = FALSE)
  checksums <- list(cs)
  names(checksums) <- filename
  do.call(write_worcsfile,
          list(filename = ".worcs",
               checksums = checksums,
               modify = TRUE)
          )
}

checksum_data_as_csv <- function(object){
  filename <- tempfile(fileext = ".csv")
  write.csv(object, filename, row.names = FALSE)
  return(digest(object = filename, file = TRUE))
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

#' @importFrom digest digest
check_sum <- function(filename){
  cs <- digest(object = filename, file = TRUE)
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

checkworcs <- function(worcs_directory, iserror = FALSE){
  if (!file.exists(file.path(worcs_directory, ".worcs"))) {
    if(iserror){
      stop(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory."
      , call. = FALSE)
    } else {
      col_message(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory. Writing .worcs file now."
      , success = FALSE)
      file.create(file.path(worcs_directory, ".worcs"))
      return(FALSE)
    }
  }
  return(TRUE)
}


write_gitig <- function(filename, ..., modify = TRUE){
  new_contents <- unlist(list(...))
  if(modify & file.exists(filename)){
    old_contents <- readLines(filename, encoding = "UTF-8")
    rep_these <- sapply(gsub("^!", "", new_contents), match, gsub("^!", "", old_contents))
    old_contents[na.omit(rep_these)] <- new_contents[!is.na(rep_these)]
    new_contents <- c(old_contents, new_contents[is.na(rep_these)])

  }
  write(new_contents, filename, append = FALSE)
}

