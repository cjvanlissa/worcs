#' @title Add synthetic data to WORCS project
#' @description This function adds a user-specified synthetic data resource for
#' public use to a WORCS project with closed data.
#' @param data A \code{data.frame} containing the synthetic data.
#' @param synthetic_name Character, naming the file synthetic data should be
#' written to. By
#' default, prepends \code{"synthetic_"} to the \code{original_name}.
#' @param original_name Character, naming an existing data resource in the WORCS
#' project with which to associate the synthetic \code{data} object.
#' @param worcs_directory Character, indicating the WORCS project directory to
#' which to save data. The default value \code{"."} points to the current
#' directory.
#' @param verbose Logical. Whether or not to print status messages to
#' the console. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "add_synthetic")
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' # Prepare data
#' df <- iris[1:3, ]
#' # Run closed_data without synthetic
#' closed_data(df, codebook = NULL, synthetic = FALSE)
#' # Manually add synthetic
#' add_synthetic(df, original_name = "df.csv")
#' # Remove original from file and environment
#' file.remove("df.csv")
#' rm(df)
#' # See that load_data() now loads the synthetic file
#' load_data()
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname add_synthetic
add_synthetic <- function(data,
                          synthetic_name = paste0("synthetic_", original_name),
                          original_name,
                          worcs_directory = ".",
                          verbose = TRUE,
                          ...){
  cl <- as.list(match.call()[-1])
  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- path_abs_worcs(".worcs", dn_worcs)
  if(!file.exists(fn_worcs)){
    stop(".worcs file not found.")
  }
  worcs_file <- read_yaml(fn_worcs)
  if(is.null(worcs_file[["data"]])){
    stop("This WORCS project does not contain any data resources.", call. = FALSE)
  }
  data_names <- names(worcs_file$data)
  if(!original_name %in% data_names){
    stop("This WORCS project does not contain a data resource called ", original_name, ". The available data resources are called:", paste0("\n  ", data_names, collapse = ""), call. = FALSE)
  }
  fn_gitig <- file.path(dn_worcs, ".gitignore")
  fn_original <- basename(original_name)
  dn_original <- dirname(original_name)
  fn_synthetic <- synthetic_name

  if(!dn_original == "."){
    fn_synthetic <- file.path(dn_original, fn_synthetic)
  }

  #fn_write_original <- file.path(dn_original, fn_original)
  fn_write_synth_abs <- path_abs_worcs(fn_synthetic, dn_worcs)
  fn_write_synth_rel <- path_rel_worcs(fn_write_synth_abs, dn_worcs)
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

  # Prepare for writing to worcs file
  to_worcs <- list(
    filename = fn_worcs,
    modify = TRUE
  )
  #to_worcs$data[[original_name]][["synthetic"]] <- vector(mode = "list")



  # Synthetic data
  col_message("Storing synthetic data in '", fn_write_synth_rel, "' and updating the checksum in '.worcs'.", verbose = verbose)


  # Obtain save_expression from the worcs_file
  save_expression <- worcs_file$data[[original_name]][["save_expression"]]
  # If there is no save_expression, this is a legacy worcs_file.
  # Use the default save expression of previous worcs versions.
  if(is.null(save_expression)){
    save_expression <- "write.csv(data, filename, row.names = FALSE)"
  }
  # Create an environment in which to evaluate the save_expression, in which
  # filename is an object with value equal to fn_write_synth
  save_env <- new.env()
  assign(x = "filename", value = fn_write_synth_abs, envir = save_env)
  out <- eval(parse(text = save_expression), envir = save_env)
  # Add info to worcs_file
  to_worcs$data[[original_name]]$synthetic <- fn_write_synth_rel
  store_checksum(fn_write_synth_abs, entry_name = fn_write_synth_rel, worcsfile = fn_worcs)
  write_gitig(fn_gitig, paste0("!", basename(fn_synthetic)))
  col_message("Updating '.gitignore'.", verbose = verbose)
  fn_readme <- path_abs_worcs("README.md", dn_worcs)
  if(file.exists(fn_readme)){
    lnz <- readLines(fn_readme)
    if(!any(grepl("Synthetic data with similar", lnz, fixed = TRUE))){
      update_textfile(filename = fn_readme,
                      txt = "Synthetic data with similar characteristics to the original data have been provided. Using the function load_data() will load these synthetic data when the original data are unavailable. Note that these synthetic data cannot be used to reproduce the original results. However, it does allow users to run the code and, optionally, generate valid code that can be evaluated using the original data by the project authors.",
                      next_to = "Some of the data used in this project are not publically available.",
                      verbose = verbose)
    }
  }

  do.call(write_worcsfile, to_worcs)
  invisible(NULL)
}

update_textfile <- function(filename, txt, next_to = NULL, before = FALSE, verbose = TRUE){
  # Update readme file
  tryCatch({
    if(file.exists(filename)){
      contentz <- readLines(filename)
      if(!is.null(next_to)){
        the_matches <- grepl(next_to, contentz, fixed = TRUE)
        if(any(the_matches)){
          loc <- which(the_matches)[1]
          out <- append(contentz, txt, after = loc-before)
          write_as_utf(out, con = filename, append = FALSE)
          col_message("Updating ", filename, ".", verbose = verbose)
          return(invisible(NULL))
        }
      }
      write_as_utf(txt, con = filename, append = TRUE)
      col_message("Appending ", filename, ".", verbose = verbose)
    } else {
      write_as_utf(txt, con = filename, append = FALSE)
      col_message("Creating ", filename, ".", verbose = verbose)
    }
  }, error = function(e){
    col_message("Failed to update file ", filename, verbose = verbose, success = FALSE)
  })
}
