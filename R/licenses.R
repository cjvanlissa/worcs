#' @title Add License File to Project
#' @description This function wraps `usethis`'
#' \code{\link[usethis:licenses]{licenses}} functions, which are
#' designed for R-packages. This function makes them applicable to other use
#' cases (e.g., WORCS projects, FAIR theory).
#' @param path Character, indicating the directory in which to create the
#' license file. Default: '.'.
#' @param license Character, indicating which license function to call.
#' The `usethis` functions all have the form `use_{licensename}_license()`.
#' The `license` argument consists only of the `{licensename}`, e.g. `ccby`.
#' @param ... Additional arguments passed to `usethis` function.
#' @return No return value. This function is called for its side effects.
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)){
#' withr::with_tempdir({
#' add_license_file(path = ".",
#'                  license = "proprietary",
#'                  copyright_holder = "test")
#' })
#' }
#' @rdname add_license_file
#' @export
add_license_file <- function(path = ".", license = "ccby", ...){
  legal_licenses <- c(
    "cc0",
    "ccby",
    "gpl",
    "gpl3",
    "agpl",
    "agpl3",
    "apache",
    "apl2",
    "lgpl",
    "mit",
    "proprietary",
    "none"
  )
  if(!license %in% legal_licenses){
    cli_msg("!" = "License {.val {license}} does not correspond to any license in `usethis`, see {.code ?usethis::use_cc0_license}.")
    if(grepl("cc_by", tolower(license))) license <- "ccby"
  }
  tmpdr <- file.path(tempdir(), "lcns")
  dir.create(tmpdr)
  on.exit(unlink(tmpdr, recursive = TRUE))
  cl <- match.call()
  cl[[1L]] <- str2lang(paste0("usethis::use_", license, "_license"))
  cl[["path"]] <- NULL
  cl[["license"]] <- NULL
  dots <- list(...)
  if(length(dots) > 0) cl[names(dots)] <- dots
  with_cli_try("Writing license file", {
    if(!license %in% legal_licenses) stop()
    usethis::ui_silence({
      usethis::with_project(tmpdr, code = {
        eval.parent(cl)
      }, force = TRUE)
    })
    flz <- list.files(tmpdr)
    flz <- grep("^license", flz, ignore.case = TRUE, value = TRUE)
    if(!length(flz) == 1) stop()
    out <- file.copy(file.path(tmpdr, flz), to = file.path(path, flz))
    if(!out) stop()
  })
}
