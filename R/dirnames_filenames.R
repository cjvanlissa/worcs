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

#' @title Return Absolute File Path of WORCS Project Directory
#' @description The search starts at `path`, and recursively proceeds up the
#' directory hierarchy until a `worcs` project directory is found.
#' @param path Start directory, Default: '.' (current directory).
#' @return Normalized path of the `worcs` project root directory.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)){
#' withr::with_tempdir({
#' writeLines("", ".worcs")
#' worcs_root()
#' })
#' }
#' @seealso
#'  \code{\link[rprojroot]{find_root}}
#' @rdname worcs_root
#' @export
#' @importFrom rprojroot find_root
worcs_root <- function(path = "."){
  tryCatch(rprojroot::find_root(".worcs", path = path), error = function(e){
    cli_msg("!" = "Could not find a `worcs` project in {.file {path}} or its parent directories.")
    return(normalizePath(path))
  })
}

#' @title Specify File Path Relative to WORCS Project Directory
#' @description Construct the path to a file inside a `worcs` project directory
#' in a platform-independent way, see \link[base]{file.path}.
#' @param ... Character vectors, indicating directory- or file names.
#' @param worcs_directory The project directory (or one of its subdirectories,
#' in which case the project directory is determined via
#' \link[worcs]{worcs_root}), Default: '.' (current directory).
#' @param fsep Path separator to use.
#' @return Normalized path to file.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)){
#' withr::with_tempdir({
#' writeLines("", ".worcs")
#' writeLines("hello world", "myfile.txt")
#' file.exists(worcs_path("myfile.txt"))
#' })
#' }
#' @rdname worcs_path
#' @export
worcs_path <- function(..., worcs_directory = ".", fsep = .Platform$file.sep){
  file.path(rprojroot::find_root(".worcs", path = worcs_directory), ..., fsep = fsep)
}
