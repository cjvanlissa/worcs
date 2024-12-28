#' @title Add License File to Project
#' @description This function wraps `usethis`'
#' \code{\link[usethis:licenses]{licenses}} functions, which are
#' designed for R-packages. This function makes them applicable to other use
#' cases (e.g., WORCS projects, FAIR theory).
#' @param repo Character, indicating the directory in which to create the
#' license file. Default: '.'.
#' @param license Character, indicating which license function to call.
#' The `usethis` functions all have the form `use_{licensename}_license()`.
#' The `license` argument consists only of the `{licensename}`, e.g. `ccby`.
#' @param ... Additional arguments passed to `usethis` function.
#' @return No return value. This function is called for its side effects.
#' @examples
#' tmpdr <- file.path(tempdir(), "license")
#' dir.create(tmpdr)
#' add_license_file(repo = tmpdr,
#'                  license = "proprietary",
#'                  copyright_holder = "test")
#' unlink(tmpdr, recursive = TRUE)
#' @rdname add_license_file
#' @export
add_license_file <- function(repo = ".", license = "ccby", ...){
  tmpdr <- file.path(tempdir(), "lcns")
  dir.create(tmpdr)
  on.exit(unlink(tmpdr, recursive = TRUE))
  cl <- match.call()
  cl[[1L]] <- str2lang(paste0("usethis::use_", license, "_license"))
  cl[["repo"]] <- NULL
  cl[["license"]] <- NULL
  tryCatch({
    cli::cli_process_start("Writing license file")
    usethis::ui_silence({
      usethis::with_project(tmpdr, code = {
        eval.parent(cl)
      }, force = TRUE)
    })
    flz <- list.files(tmpdr)
    flz <- grep("^license", flz, ignore.case = TRUE, value = TRUE)
    if(!length(flz) == 1) stop()
    out <- file.copy(file.path(tmpdr, flz), to = file.path(repo, flz))
    if(!out) stop()
    cli::cli_process_done() },
    error = function(err) {
      cli::cli_process_failed()
    }
  )
  invisible()
}
