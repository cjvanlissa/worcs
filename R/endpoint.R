#' @title Add endpoint to WORCS project
#' @description Add a specific endpoint to the WORCS project file. Endpoints are
#' files that are expected to be exactly reproducible (e.g., a manuscript,
#' figure, table, et cetera). Reproducibility is checked by ensuring the
#' endpoint's checksum is unchanged.
#' @param filename Character, indicating the file to be tracked as endpoint.
#' Default: NULL.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: TRUE
#' @param ... Additional arguments.
#' @return No return value. This function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "add_endpoint")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' writeLines("test", "test.txt")
#' add_endpoint("test.txt")
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname add_endpoint
#' @seealso
#'  \code{\link[worcs]{snapshot_endpoints}}
#'  \code{\link[worcs]{check_endpoints}}
#' @export
#' @importFrom yaml read_yaml
add_endpoint <- function(filename = NULL, worcs_directory = ".", verbose = TRUE, ...){
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory),
                                                        ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  worcsfile <- yaml::read_yaml(fn_worcs)
  endpoints <- worcsfile[["endpoints"]]
  # if(is.null(entry_point)){
  #   if(is.null(worcsfile[["entry_point"]])){
  #     stop("No 'entry_point' specified, and the project contains no existing entry points.")
  #   } else {
  #     if(length(worcsfile[["entry_point"]]) > 1){
  #       stop("No 'entry_point' specified, and the project contains multiple entry points. Specify one of the following: ", paste0("'", names(worcsfile[["entry_point"]])))
  #     }
  #   }
  #
  # }
  fn_endpoint <- path_abs_worcs(filename, dn_worcs)
  if(!file.exists(fn_endpoint)){
    stop("The file does not exist: ", filename)
  }
  endpoints <- append(endpoints, filename)
  endpoints <- unique(endpoints)
  # Append worcsfile
  tryCatch({
    if(!is_quiet()) cli::cli_process_start("Adding endpoint {.val {filename}} to '.worcs'.")
    write_worcsfile(filename = fn_worcs, endpoints = endpoints, modify = TRUE)
    store_checksum(fn_endpoint, entry_name = filename, worcsfile = fn_worcs)
    cli::cli_process_done() },
    error = function(err) {
      cli::cli_process_failed()
    }
  )
  invisible()
}

#' @title Snapshot endpoints in WORCS project
#' @description Update the checksums of all endpoints in a WORCS project.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: TRUE
#' @param ... Additional arguments.
#' @return No return value. This function is called for its side effects.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "update_endpoint")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' writeLines("test", "test.txt")
#' add_endpoint("test.txt")
#' writeLines("second test", "test.txt")
#' snapshot_endpoints()
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{check_endpoints}}
#' @export
snapshot_endpoints <- function(worcs_directory = ".", verbose = TRUE, ...){
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory),
                                                        ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  worcsfile <- yaml::read_yaml(fn_worcs)
  if(is.null(worcsfile[["endpoints"]])){
    col_message("No endpoints found in WORCS project.", verbose = verbose, success = FALSE)
  }
  endpoints <- worcsfile[["endpoints"]]
  for(ep in endpoints){
    tryCatch({
      if(!is_quiet()) cli::cli_process_start("Update snapshot of endpoint {.val {ep}}.")
      fn_endpoint <- path_abs_worcs(ep, dn_worcs)
      store_checksum(fn_endpoint, entry_name = ep, worcsfile = fn_worcs)
      cli::cli_process_done() },
      error = function(err) {
        cli::cli_process_failed()
      }
    )
  }
}

#' @title Check endpoints in WORCS project
#' @description Check that the checksums of all endpoints in a WORCS project
#' match their snapshots.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: TRUE
#' @param ... Additional arguments.
#' @return Returns a logical value (TRUE/FALSE) invisibly.
#' @examples
#' # Create directory to run the example
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "check_endpoint")
#' dir.create(test_dir)
#' setwd(test_dir)
#' file.create(".worcs")
#' writeLines("test", "test.txt")
#' add_endpoint("test.txt")
#' check_endpoints()
#' # Cleaning example directory
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{snapshot_endpoints}}
#' @export
check_endpoints <- function(worcs_directory = ".", verbose = TRUE, ...){
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory),
                                                        ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  worcsfile <- yaml::read_yaml(fn_worcs)
  if(is.null(worcsfile[["endpoints"]])){
    if(interactive()){
      col_message("No endpoints found in WORCS project.", verbose = verbose, success = FALSE)
    } else {
      stop("No endpoints found in WORCS project.")
    }

  }
  endpoints <- worcsfile[["endpoints"]]
  replicates <- rep(x = TRUE, times = length(endpoints))
  for(i in seq_along(endpoints)){
    ep <- endpoints[i]
    out <- try({
      #fn_endpoint <- path_abs_worcs(ep, dn_worcs)
      # Use absolute file path here
      check_sum(file.path(dn_worcs, ep), old_cs = worcsfile[["checksums"]][[ep]], worcsfile = fn_worcs, error = TRUE)
    }, silent = TRUE)
    if(inherits(out, "try-error")){
      col_message("Endpoint '", ep, "' did not replicate.",
                          verbose = verbose, success = FALSE)
      replicates[i] <- FALSE
    } else {
      col_message("Endpoint '", ep, "' replicates.",
                          verbose = verbose)
    }
  }
  if(!interactive()){
    if(any(!replicates)){
      # git_record <- system2("git", paste0('-C "', dirname(fn_worcs), '" ls-files --eol'), stdout = TRUE)
      # git_record <- git_record[grepl(endpoints[1], git_record, fixed = TRUE)]
      # stop("Endpoints ", paste0(endpoints[which(!replicates)], collapse = ", "), " did not replicate. Checksum of record: ", worcsfile[["checksums"]][[endpoints[1]]], ", local checksum: ", cs_fun(ep, fn_worcs), ", git ls: ", git_record)
      stop("Endpoints ", paste0(endpoints[which(!replicates)], collapse = ", "), " did not replicate. Make sure that the endpoint snapshot and renv are up to date, and verify that differences are not due to Git changing the line endings of text files.")
    }
  }
  return(invisible(all(replicates)))
}


#' @title List endpoints in WORCS project
#' @description List the endpoints in a WORCS project.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: TRUE
#' @param ... Additional arguments.
#' @return None, prints to the console.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)){
#'   withr::with_tempdir({
#'     file.create(".worcs")
#'     write.csv(iris, "iris.csv")
#'     add_endpoint("iris.csv")
#'     list_endpoints()
#'   })
#' }
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{snapshot_endpoints}}
#' @export
list_endpoints <- function(worcs_directory = ".", verbose = TRUE, ...){
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory),
                                                ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  worcsfile <- yaml::read_yaml(fn_worcs)
  if(is.null(worcsfile[["endpoints"]])){
    cli_msg("x" = "No endpoints found in WORCS project.")
  } else {
    endpoints <- worcsfile[["endpoints"]]
    names(endpoints) <- rep("*", length(endpoints))
    do.call(cli_msg, as.list(endpoints))
  }
}

#' @title Remove endpoint from WORCS project
#' @description Remove an endpoint from a WORCS project.
#' @param worcs_directory Character, indicating the WORCS project directory
#' to which to save data. The default value "." points to the current directory.
#' Default: '.'
#' @param filename Character, indicating the file to be removed from the
#' endpoints.
#' Default: NULL.
#' @param verbose Logical. Whether or not to print status messages to the
#' console. Default: TRUE
#' @param ... Additional arguments.
#' @return None, prints to the console.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)){
#'  withr::with_tempdir({
#'    file.create(".worcs")
#'    write.csv(iris, "iris.csv")
#'    add_endpoint("iris.csv")
#'    list_endpoints()
#'    remove_endpoint("iris.csv")
#'    list_endpoints()
#'  })
#' }
#' @seealso
#'  \code{\link[worcs]{add_endpoint}}
#'  \code{\link[worcs]{snapshot_endpoints}}
#' @export
remove_endpoint <- function(filename = NULL, worcs_directory = ".", verbose = TRUE, ...){
  if(is.null(filename)){
    return(invisible(NULL))
  }
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory),
                                                ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  worcsfile <- yaml::read_yaml(fn_worcs)
  if(is.null(worcsfile[["endpoints"]])){
    cli_msg("x" = "No endpoints found in WORCS project.")
  } else {
    endpoints <- worcsfile[["endpoints"]]
    with_cli_try("Removing endpoint {.val {filename}} from WORCS project.", {
      if(filename %in% endpoints){
        endpoints <- endpoints[-which(endpoints == filename)]
        # Append worcsfile
        write_worcsfile(filename = fn_worcs, endpoints = endpoints, modify = TRUE)
      } else {
        stop()
      }
    })
  }
  invisible()
}
