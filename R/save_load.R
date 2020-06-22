#' @title Use open data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
#' and amends the \code{.gitignore} file to exclude \code{filename}.
#' @param data A data.frame to save.
#' @param filename Character, naming the file data should be written to.
#' @param codebook Character, naming the file the codebook should be written to.
#' An 'R Markdown' codebook will be created and rendered to
#' \code{\link[rmarkdown]{github_document}} ('markdown' for 'GitHub').
#' Defaults to 'codebook.Rmd'. Set to \code{NULL} to avoid creating a codebook.
#' @param worcs_directory Character, indicating the WORCS project directory to
#' which to save data. The default value \code{"."} points to the current
#' directory.
#' @param ... Additional arguments passed to and from functions.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' test_dir <- file.path(tempdir(), "data")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' open_data(iris[1:5, ], codebook = "bla.Rmd")
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname open_data
open_data <- function(data, filename = "data.csv", codebook = "codebook.Rmd", worcs_directory = ".", ...){
  Args <- as.list(match.call()[-1])
  Args$open <- TRUE
  do.call(save_data, Args)
}

#' @title Use closed data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
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
#' worcs:::write_worcsfile(".worcs")
#' closed_data(iris[1:10, ], codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname closed_data
closed_data <- function(data,
                        filename = "data.csv",
                        codebook = "codebook.Rmd", worcs_directory = ".", ...){
  Args <- as.list(match.call()[-1])
  Args$open <- FALSE
  do.call(save_data, Args)
}

#' @importFrom digest digest
#' @importFrom utils write.csv
save_data <- function(data,
                      filename = "data.csv",
                      open,
                      codebook = "codebook.Rmd", worcs_directory = "."){
  cl <- as.list(match.call()[-1])
  create_codebook <- !is.null(codebook)
  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  fn_gitig <- file.path(dn_worcs, ".gitignore")
  fn_original <- basename(filename)
  dn_original <- dirname(filename)
  fn_synthetic <- paste0("synthetic_", fn_original)
  if(!dn_original == "."){
    fn_synthetic <- file.path(dn_original, fn_synthetic)
  }
  fn_write_original <- file.path(dn_worcs, filename)
  fn_write_synth <- file.path(dn_worcs, fn_synthetic)
  fn_write_codebook <- file.path(dn_worcs, codebook)
  # End filenames

  # Remove this when worcs can handle different types:
  if(!inherits(data, c("data.frame", "matrix"))){
    stop("Argument 'data' must be a data.frame, matrix, or inherit from these classes.")
  }
  # End remove

  # Insert three checks:
  # 1) write_func works with data object
  # 2) read_func works with data object
  # 3) result of read_func is identical to data object

# Store data --------------------------------------------------------------

  col_message("Storing original data in '", filename, "' and updating the checksum in '.worcs'.")
  write.csv(data, fn_write_original, row.names = FALSE)

  # Prepare for writing to worcs file
  to_worcs <- list(
    filename = fn_worcs,
    modify = TRUE
  )
  to_worcs$data[[filename]] <- vector(mode = "list")
  store_checksum(fn_write_original, entry_name = filename)

  if(open){
    write_gitig(fn_gitig, paste0("!", basename(fn_original)))
  } else {
    # Synthetic data
    col_message("Generating synthetic data for public use. Ensure that no identifying information is included.")
    synth_success <- tryCatch({
      synth <- synthetic(data, verbose = FALSE)
      TRUE
      }, error = function(e){
        FALSE
      })
    if(synth_success){
      col_message("Storing synthetic data in '", fn_synthetic, "' and updating the checksum in '.worcs'.")
      write.csv(synth, fn_write_synth, row.names = FALSE)
      to_worcs$data[[filename]]$synthetic <- fn_synthetic
      store_checksum(fn_write_synth, entry_name = fn_synthetic)

      write_gitig(fn_gitig, basename(fn_original))
      write_gitig(fn_gitig, paste0("!", basename(fn_synthetic)))
    } else {
      col_message("Could not generate synthetic data.")
    }
  }
  col_message("Updating '.gitignore'.")

# codebook ----------------------------------------------------------------
  if(create_codebook){
    Args_cb <- cl["data"]
    Args_cb$filename <- fn_write_codebook
    cb_out <- capture.output(do.call(make_codebook, Args_cb))
    # Add to gitignore
    write_gitig(filename = fn_gitig, paste0("!", gsub(".md$", "csv", basename(fn_write_codebook))))
    # Add to worcs
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
#' worcs:::write_worcsfile(".worcs")
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
  # When users work from Rmd in a subdirectory, the working directory will be
  # set to that subdirectory. Check for .worcs file recursively, and change
  # directory if necessary.

  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  checkworcs(dn_worcs, iserror = TRUE)

  fn_worcs <- file.path(dn_worcs, ".worcs")
  # End filenames

  worcsfile <- read_yaml(fn_worcs)
  if(is.null(worcsfile[["data"]])){
    stop("No data found in '.worcs'.")
  }
  data <- worcsfile$data
  data_files <- names(data)
  fn_data_files <- file.path(dn_worcs, data_files)
  data_original <- sapply(fn_data_files, function(i){file.exists(i)})
  if(any(!data_original)){
     data_files_synth <- sapply(data_files[!data_original], function(i){
      worcsfile$data[[i]][["synthetic"]]
      })
  data_files[!data_original] <- data_files_synth
  fn_data_files[!data_original] <- file.path(dn_worcs, data_files_synth)
  }
  data_files <- data_files[!(is.null(data_files)|is.na(data_files))]
  data_original <- data_original[!(is.null(data_files)|is.na(data_files))]
  if(length(data_files) == 0) stop("No valid data files found.")
  outlist <- vector(mode = "list")
  for(file_num in seq_along(data_files)){
    fn_this_file <- fn_data_files[file_num]
    data_name_this_file <- data_files[file_num]
    check_sum(fn_this_file, worcsfile$checksums[[data_name_this_file]])
    col_message("Loading ", c("synthetic", "original")[data_original[file_num]+1], " data from '", data_name_this_file, "'.")
    object_name <- sub('^(synthetic_)?(.+)\\..*$', '\\2', basename(data_name_this_file))
    # Replace this with flexible load function from .worcs file
    out <- read.csv(fn_this_file, stringsAsFactors = TRUE)
    attr(out, "type") <- c("synthetic", "original")[data_original[file_num]+1]
    class(out) <- c("worcs_data", class(out))
    if(to_envir){
      if(object_name %in% objects(envir = envir)) warning("Object '", object_name, "' already exists in the environment designated by 'envir', and will be replaced with the contents of '", data_name_this_file, "'.")
      assign(object_name, out, envir = envir)
    } else {
      outlist[[object_name]] <- out
    }
  }
  return(invisible(outlist))
}

#' @importFrom digest digest
store_checksum <- function(filename, entry_name = filename, worcsfile = ".worcs") {
  # Compute checksum on loaded data to ensure conformity
  cs <- digest(object = filename, file = TRUE)
  checkworcs(dirname(filename), iserror = FALSE)
  checksums <- list(cs)
  names(checksums) <- entry_name
  do.call(write_worcsfile,
          list(filename = worcsfile,
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
check_sum <- function(filename, old_cs = NULL){
  cs <- digest(object = filename, file = TRUE)
  if(is.null(old_cs)){
    old_cs <- load_checksum(filename = filename)
  }
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

check_recursive <- function(path){
  tryCatch({ normalizePath(path) },
           warning = function(e){
             filename <- basename(path)
             cur_dir <- dirname(path)
             parent_dir <- dirname(dirname(path))
             if(cur_dir == parent_dir){
               stop("No '.worcs' file found in this directory or any of its parent directories; either this is not a worcs project, or the working directory is not set to the project directory.")
             }
             check_recursive(file.path(parent_dir, filename))
           })
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

