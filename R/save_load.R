#' @title Use open data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
#' and amends the \code{.gitignore} file to exclude \code{filename}.
#' @param data A data.frame to save.
#' @param filename Character, naming the file data should be written to. By
#' default, constructs a filename from the name of the object passed to
#' \code{data}.
#' @param codebook Character, naming the file the codebook should be written to.
#' An 'R Markdown' codebook will be created and rendered to
#' \code{\link[rmarkdown]{github_document}} ('markdown' for 'GitHub').
#' By default, constructs a filename from the name of the object passed to
#' \code{data}, adding the word 'codebook'.
#' Set this argument to \code{NULL} to avoid creating a codebook.
#' @param value_labels Character, naming the file the value labels of factors
#' and ordinal variables should be written to.
#' By default, constructs a filename from the name of the object passed to
#' \code{data}, adding the word 'value_labels'.
#' Set this argument to \code{NULL} to avoid creating a file with value labels.
#' @param worcs_directory Character, indicating the WORCS project directory to
#' which to save data. The default value \code{"."} points to the current
#' directory.
#' @param save_expression An R-expression used to save the \code{data}.
#' Defaults to \code{write.csv(x = data, file = filename, row.names = FALSE)},
#' which writes a comma-separated, spreadsheet-style file.
#' The arguments \code{data} and \code{filename} are passed from
#' \code{open_data()} to the expression defined in \code{save_expression}.
#' @param load_expression An R-expression used to load the \code{data} from the
#' file created by \code{save_expression}. Defaults to
#' \code{read.csv(file = filename, stringsAsFactors = TRUE)}. This expression
#' is stored in the project's \code{.worcs} file, and invoked by
#' \code{load_data()}.
#' @param ... Additional arguments passed to and from functions.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' test_dir <- file.path(tempdir(), "data")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' df <- iris[1:5, ]
#' open_data(df, codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname open_data
open_data <- function(data,
                      filename = paste0(deparse(substitute(data)), ".csv"),
                      codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                      value_labels = paste0("value_labels_", deparse(substitute(data)), ".yml"),
                      worcs_directory = ".",
                      save_expression = write.csv(x = data, file = filename, row.names = FALSE),
                      load_expression = read.csv(file = filename, stringsAsFactors = TRUE),
                      ...){
  Args <- match.call()
  Args$open <- TRUE
  Args$save_expression <- substitute(save_expression)
  Args$load_expression <- substitute(load_expression)
  Args[[1L]] <- str2lang("worcs:::save_data")
  eval(Args, parent.frame())
}

#' @title Use closed data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
#' appends the \code{.gitignore} file to exclude \code{filename}, and saves a
#' synthetic copy of \code{data} for public use. To generate these synthetic
#' data, the function \code{\link{synthetic}} is used.
#' @inheritParams open_data
#' @param synthetic Logical, indicating whether or not to create a synthetic
#' dataset using the \code{\link{synthetic}} function. Additional arguments for
#' the call to \code{\link{synthetic}} can be passed through \code{...}.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "data")
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' df <- iris[1:3, ]
#' closed_data(df, codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname closed_data
closed_data <- function(data,
                        filename = paste0(deparse(substitute(data)), ".csv"),
                        codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                        value_labels = paste0("value_labels_", deparse(substitute(data)), ".yml"),
                        worcs_directory = ".",
                        synthetic = TRUE,
                        save_expression = write.csv(x = data, file = filename, row.names = FALSE),
                        load_expression = read.csv(file = filename, stringsAsFactors = TRUE),
                        ...){
  Args <- match.call()
  Args$open <- FALSE
  Args$save_expression <- substitute(save_expression)
  Args$load_expression <- substitute(load_expression)
  Args[[1L]] <- str2lang("worcs:::save_data")
  eval(Args, parent.frame())
}

#' @importFrom digest digest
#' @importFrom utils write.csv
save_data <- function(data,
                      filename = paste0(deparse(substitute(data)), ".csv"),
                      open,
                      codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                      value_labels = paste0("value_labels_", deparse(substitute(data)), ".yml"),
                      worcs_directory = ".",
                      verbose = TRUE,
                      synthetic = TRUE,
                      save_expression = write.csv(x = data, file = filename, row.names = FALSE),
                      load_expression = read.csv(file = filename, stringsAsFactors = TRUE),
                      ...){
  # Find .worcs file
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))

  if(grepl("[", filename, fixed = TRUE) | grepl("$", filename, fixed = TRUE)){
    stop("This filename is not allowed: ", filename, ". Please specify a legal filename.", call. = FALSE)
  }
  cl <- as.list(match.call()[-1])
  create_codebook <- !is.null(codebook)
  create_labels <- !is.null(value_labels)


# Filenames housekeeping --------------------------------------------------
  if(create_codebook){
    if(grepl("[", codebook, fixed = TRUE) | grepl("$", codebook, fixed = TRUE)){
    stop("This codebook filename is not allowed: ", codebook, ". Please specify a legal filename.", call. = FALSE)
    }
    fn_write_codebook <- path_abs_worcs(codebook, dn_worcs)
  }

  if(create_labels){
    if(grepl("[", value_labels, fixed = TRUE) | grepl("$", value_labels, fixed = TRUE)){
      stop("This filename is not allowed: ", value_labels, ". Please specify a legal filename.", call. = FALSE)
    }
    fn_write_labels <- path_abs_worcs(value_labels, dn_worcs)
  }
  # Filenames housekeeping
  fn_worcs <- path_abs_worcs(".worcs", dn_worcs)
  fn_gitig <- path_abs_worcs(".gitignore", dn_worcs)
  fn_original <- basename(filename)
  dn_original <- dirname(filename)

  fn_synthetic <- paste0("synthetic_", fn_original)
  if(!dn_original == "."){
    fn_synthetic <- file.path(dn_original, fn_synthetic)
  }

  fn_write_original <- path_abs_worcs(filename, dn_worcs)
  fn_write_synth <- path_abs_worcs(fn_synthetic, dn_worcs)

  # End filenames

  # Remove this when worcs can handle different types:
  # if(!inherits(data, c("data.frame", "matrix"))){
  #   stop("Argument 'data' must be a data.frame, matrix, or inherit from these classes.")
  # }
  # End remove

  # Insert three checks:
  # 1) write_func works with data object
  # 2) read_func works with data object
  # 3) result of read_func is identical to data object

# Store data --------------------------------------------------------------

  col_message("Storing original data in '", filename, "' and updating the checksum in '.worcs'.", verbose = verbose)
  filename <- fn_write_original
  eval(substitute(save_expression))

  # Prepare for writing to worcs file
  to_worcs <- list(
    filename = fn_worcs,
    modify = TRUE
  )
  filename <- path_rel_worcs(filename, dn_worcs)
  to_worcs$data[[filename]] <- vector(mode = "list")
  to_worcs$data[[filename]][["save_expression"]] <- deparse(substitute(save_expression))
  to_worcs$data[[filename]][["load_expression"]] <- deparse(substitute(load_expression))
  do.call(write_worcsfile, to_worcs)
  store_checksum(fn_write_original, entry_name = filename, worcsfile = fn_worcs)

  if(open){
    write_gitig(fn_gitig, paste0("!", filename))
  } else {
    write_gitig(fn_gitig, filename)
    # Update readme file with message about closed data
    fn_readme <- path_abs_worcs("README.md", dn_worcs)
    if(file.exists(fn_readme)){
      lnz <- readLines(fn_readme)
      if(!any(grepl("not publically available", lnz, fixed = TRUE))){
        update_textfile(fn_readme,
                        "\n\n## Access to data\n\nSome of the data used in this project are not publically available.\nTo request access to the original data, [open a GitHub issue](https://docs.github.com/en/free-pro-team@latest/github/managing-your-work-on-github/creating-an-issue).\n\n<!--Clarify here how users should contact you to gain access to the data, or to submit syntax for evaluation on the original data.-->",
                        verbose = verbose)
      }

    }

    if(synthetic){
      # Synthetic data
      col_message("Generating synthetic data for public use. Ensure that no identifying information is included.", verbose = verbose)
      Args <- match.call()
      Args <- Args[c(1, which(names(Args) %in% names(formals("synthetic"))))]
      Args$verbose <- verbose
      Args[[1L]] <- quote(worcs::synthetic)
      synth <- eval.parent(Args)
      add_synthetic(data = synth,
                    synthetic_name = fn_synthetic,
                    original_name = filename,
                    worcs_directory = dn_worcs,
                    verbose = verbose)
    }
  }
  col_message("Updating '.gitignore'.", verbose = verbose)

# codebook ----------------------------------------------------------------
  if(create_codebook){
    col_message("Creating a codebook in '", codebook, "'.", success = TRUE, verbose = verbose)
    Args_cb <- match.call()
    Args_cb[[1L]] <- str2lang("make_codebook")
    Args_cb <- Args_cb[c(1L, match("data", names(Args_cb)))]
    Args_cb$filename <- fn_write_codebook
    cb_out <- capture.output(eval.parent(Args_cb))
    # Add to gitignore
    write_gitig(filename = fn_gitig, paste0("!", gsub(".md$", "csv", path_rel_worcs(fn_write_codebook))))
    # Add to worcs
    to_worcs <- list(filename = fn_worcs,
                     "data" = list(list("codebook" = path_rel_worcs(fn_write_codebook))),
                     modify = TRUE)

    names(to_worcs[["data"]])[1] <- filename
    do.call(write_worcsfile, to_worcs)

  }

# Value labels ------------------------------------------------------------
  has_factors <- any(sapply(data, inherits, what = "factor"))
  if(create_labels & has_factors){
    col_message("Storing value labels in '", path_rel_worcs(fn_write_labels, dn_worcs), "'.", success = TRUE, verbose = verbose)
    make_labels(data = data,
                variables = names(data)[sapply(data, inherits, what = "factor")],
                fn_write_labels
                )
    # Add to worcs
    to_worcs <- list(filename = fn_worcs,
                     data = list(list(labels = value_labels)), modify = TRUE)

    names(to_worcs[["data"]])[1] <- filename
    do.call(write_worcsfile, to_worcs)

  }
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
#' @param verbose Logical. Whether or not to print status messages to
#' the console. Default: TRUE
#' @param use_metadata Logical. Whether or not to use the codebook and
#' value labels and attempt to coerce the class and values of variables to
#' those recorded therein. Default: TRUE
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
#' df <- iris[1:5, ]
#' suppressWarnings(closed_data(df, codebook = NULL))
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
load_data <- function(worcs_directory = ".", to_envir = TRUE, envir = parent.frame(1),
                      verbose = TRUE, use_metadata = TRUE){
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
  names(data_files) <- data_files
  fn_data_files <- file.path(dn_worcs, data_files)
  data_original <- sapply(fn_data_files, function(i){file.exists(i)})
  data_files_synth <- rep(NA, length(data_files))
  if(any(!data_original)){
     for(i in data_files[!data_original]){
       if(is.null(worcsfile$data[[i]][["synthetic"]])){
         col_message("Cannot find the original data ", i, ", and there is no synthetic version on record.", success = FALSE, verbose = verbose)
       } else {
         data_files_synth <- worcsfile$data[[i]][["synthetic"]]
       }
      }

     data_files[!data_original] <- data_files_synth
     fn_data_files[!data_original] <- file.path(dn_worcs, data_files_synth)
  }
  if(anyNA(data_files)){
    col_message("No valid resource found for these files:", paste0("\n  * ", names(data_files)[is.na(data_files)]), success = FALSE, verbose = verbose)
  }
  data_files <- data_files[!(is.null(data_files)|is.na(data_files))]

  data_original <- data_original[!(is.null(data_files)|is.na(data_files))]
  if(length(data_files) == 0) stop("No valid data files found.")
  outlist <- vector(mode = "list")
  for(file_num in seq_along(data_files)){
    fn_this_file <- fn_data_files[file_num]
    data_name_this_file <- data_files[file_num]
    check_sum(fn_this_file, worcsfile$checksums[[data_name_this_file]])
    col_message("Loading ", c("synthetic", "original")[data_original[file_num]+1], " data from '", data_name_this_file, "'.", verbose = verbose)
    object_name <- sub('^(synthetic_)?(.+)\\..*$', '\\2', basename(data_name_this_file))

    # Obtain load_expression from the worcsfile
    load_expression <- worcsfile$data[[names(data_files)[file_num]]][["load_expression"]]
    # If there is no load_expression, this is a legacy worcsfile.
    # Use the default load expression of previous worcs versions.
    if(is.null(load_expression)){
      load_expression <- "read.csv(file = filename, stringsAsFactors = TRUE)"
    }
    # Create an environment in which to evaluate the load_expression, in which
    # filename is an object with value equal to fn_this_file
    load_env <- new.env()
    assign(x = "filename", value = fn_this_file, envir = load_env)
    out <- eval(parse(text = load_expression), envir = load_env)
    # Check classes
    if(use_metadata){
      codebook <- tryCatch({
        codebook <- gsub("\\.rmd$", ".csv", worcsfile$data[[names(data_files)[file_num]]][["codebook"]], ignore.case = TRUE)
        read.csv(file.path(dn_worcs, codebook), stringsAsFactors = FALSE)
      }, error = function(e){ NULL })
      value_labels <- tryCatch({
        value_labels <- worcsfile$data[[names(data_files)[file_num]]][["labels"]]
        yaml::read_yaml(file.path(dn_worcs, value_labels))
      }, error = function(e){ NULL })
      out <- check_metadata(out, codebook, value_labels)
    }
    # Update attributes and class of output object
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

# orderedvars <- sapply(out, inherits, what = "ordered")
# if(any(orderedvars)){
#   browser()
#   value_labels <- worcsfile$data[[names(data_files)[file_num]]][["labels"]]
#   value_labels <- yaml::read_yaml(value_labels)
#   for(v in names(out)[orderedvars]){
#     out[[v]] <-
#   }
# }

check_metadata <- function(x, codebook, value_labels){
  if(!is.null(codebook)){
    classes <- codebook[["type"]]
    multiclass <- grepl(",", classes, fixed = TRUE)
    if(any(multiclass)){
      classes[multiclass] <- gsub(",.*$", "", classes[multiclass])
    }
    names(classes) <- codebook[["name"]]
  } else {
    col_message("No valid codebook found.", success = FALSE)
    classes <- sapply(x, function(i){class(i)[1]})
    names(classes) <- names(x)
  }

  for(v in names(x)){
    if(!class(x[[v]])[1] == classes[v]){
      x[[v]] <- switch(classes[v],
                       ordered = {
                         tryCatch({
                           if(is.null(value_labels[[v]])) stop()
                           ordered(x[[v]], levels = unlist(value_labels[[v]][-1]))
                           },
                                  error = function(e){
                                    col_message("Could not restore class of variable '", v, "'.", success = FALSE)
                                    x[[v]]
                                  })
                       },
                       {
                         tryCatch({do.call(paste0("as.", classes[v]), list(x[[v]]))},
                                  error = function(e){
                                    message("Could not restore class of variable '", v, "'.")
                                    x[[v]]
                                  })
                       }
      )
    }
  }
  x
}

cs_fun <- function(filename){#, worcsfile = ".worcs"){
  # gitfiles <- system2("git", '-C "pathtofile" ls-files --eol', stdout = TRUE)
  # gitfiles <- gitfiles[grepl("/lf", gitfiles, fixed = TRUE)|grepl("/crlf", gitfiles, fixed = TRUE)]
  # gitfiles <- gsub("^.+attr/.+?\\t", "", gitfiles)
  suppressWarnings(digest::digest(paste0(readLines(filename), collapse = ""), serialize = FALSE, file = FALSE))
}

#' @importFrom digest digest
# @importFrom tools md5sum
store_checksum <- function(filename, entry_name = filename, worcsfile = ".worcs") {
  # Compute checksum on loaded data to ensure conformity
  #cs <- digest(object = filename, file = TRUE)
  #cs <- tools::md5sum(files = filename)
  cs <- cs_fun(filename)
  checkworcs(dirname(worcsfile), iserror = FALSE)
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
  return(cs_fun(filename))
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
  cs <- cs_fun(filename)
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
  if(!is.null(attr(x, "type"))){
    if(attr(x, "type") == "synthetic"){
      cat("This is a synthetic data set. The first 6 rows are:\n\n")
    }
    if(attr(x, "type") == "original"){
      cat("This is the original data set. The first 6 rows are:\n\n")
    }
    class(x) <- class(x)[-1]
  }
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
             doesnt_exist <- !dir.exists(cur_dir)
             if(cur_dir == parent_dir){
               stop("No '.worcs' file found in this directory or any of its parent directories; either this is not a worcs project, or the working directory is not set to the project directory.", call. = FALSE)
             } else if(doesnt_exist) {
               stop("No '.worcs' file found, because the directory '", dirname(path), "' doesn't exists.", call. = FALSE)
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

#' @title Notify the user when synthetic data are being used
#' @description This function prints a notification message when some or all of
#' the data used in a project are synthetic (see \code{\link{closed_data}} and
#' \code{\link{synthetic}}). See details for important information.
#' @details The preferred way to use this function is to provide specific data
#' objects in the function call, using the \code{...} argument.
#' If no such objects are provided, \code{notify_synthetic} will scan the
#' parent environment for objects of class \code{worcs_data}.
#'
#' This function is emphatically designed to be included in an 'R Markdown'
#' file, to dynamically generate a notification message when a third party
#' 'Knits' such a document without having access to all original data.
#' @param ... Objects of class \code{worcs_data}. The function will check if
#' these are original or synthetic data.
#' @param msg Expression containing the message to print in case not all
#' \code{worcs_data} are original. This message may refer to \code{is_synth},
#' a logical vector indicating which \code{worcs_data} objects are synthetic.
#' @return No return value. This function is called for its side effect of
#' printing a notification message.
#' @examples
#' df <- iris
#' class(df) <- c("worcs_data", class(df))
#' attr(df, "type") <- "synthetic"
#' notify_synthetic(df, msg = "synthetic")
#' @rdname notify_synthetic
#' @export
#' @seealso closed_data synthetic add_synthetic
notify_synthetic <- function(...,
                             msg = NULL){
  dots <- list(...)
  cl <- as.list(match.call()[-1])
  if(is.null(cl[["msg"]])){
    msg <- quote(c("**Note that", ifelse(all(is_synth), "all", "some"), "of the data files used to generate this document are synthetic. The original data are not available. Synthetic data can be used to evaluate the reproducibility of the analysis code, but the results should not be substantively interpreted, and will likely deviate from the results generated using the original data. Please contact the authors for more information.**"))
  }
  msg <- substitute(msg)
  if(length(dots) > 0){
    if(!all(sapply(dots, inherits, what = "worcs_data"))){
      stop("Some arguments provided to 'notify_synthetic()' are not objects of class 'worcs_data'.", call. = FALSE)
    }
    is_synth <- sapply(dots, attr, which = "type") == "synthetic"
  } else {
    worcs_data <- Filter(function(x) inherits(get(x), "worcs_data"), ls(name = parent.env(environment())))
    is_synth <- sapply(worcs_data, function(x){ attr(get(x), which = "type") }) == "synthetic"
  }
  if(any(is_synth)){
    cat(eval(msg))
  }
}

path_abs_worcs <- function(fn, dn_worcs = NULL, worcs_directory = "."){
  if(grepl("^.:", fn)){
    stop("Filename must be a relative path.", call. = FALSE)
  }
  if(is.null(dn_worcs)){
    dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  }
  invisible(checkworcs(dn_worcs, iserror = TRUE))
  basen <- basename(fn)
  dirn <- dirname(fn)
  if(dirn == "."){
    return(file.path(dn_worcs, basen))
  } else {
    return(file.path(dn_worcs, dirn, basen))
  }
}

path_rel_worcs <- function(fn, dn_worcs = NULL, worcs_directory = "."){
  if (is.null(dn_worcs)) {
    dn_worcs <-
      dirname(check_recursive(file.path(
        normalizePath(worcs_directory), ".worcs"
      )))
  }
  invisible(checkworcs(dn_worcs, iserror = TRUE))
  # Normalize both
  fn <- normalizePath(fn, winslash = .Platform$file.sep, mustWork = FALSE)
  dn_worcs <- normalizePath(dn_worcs, winslash = .Platform$file.sep)
  # Check for OS
  on_windows <- isTRUE(grepl("mingw", R.Version()$os, fixed = TRUE))
  if (on_windows) {
    dn_worcs <- tolower(dn_worcs)
    fn <- tolower(fn)
  }
  # Split pathnames into components
  dn_worcs <- unlist(strsplit(dn_worcs, split = .Platform$file.sep, fixed = TRUE))
  fn <- unlist(strsplit(fn, split = .Platform$file.sep, fixed = TRUE))
  if(length(dn_worcs) > length(fn)){
    stop("File path must be inside of the worcs project file.", call. = FALSE)
  }

  if(!all(dn_worcs == fn[seq_along(dn_worcs)])){
    stop("File path must be inside of the worcs project file.", call. = FALSE)
  }
  return(file.path(fn[-seq_along(dn_worcs)]))
}
