with_cli_try <- function(msg, code, ...){
  tryCatch({
    if(!is_quiet()) cli::cli_process_start(msg, ..., .envir = parent.frame(1))
    eval(code, envir = parent.frame())
    cli::cli_process_done()
    return(invisible(TRUE))
  }, error = function(err) {
    cli::cli_process_failed()
    return(invisible(FALSE))
  })
}

cli_msg <- function(...){
  if(!is_quiet()) do.call(cli::cli_bullets, list(text = as.vector(list(...))), envir = parent.frame(n = 2))
}

is_quiet <- function() {
  isTRUE(getOption("usethis.quiet", default = FALSE))
}

#' @importFrom usethis ui_oops ui_done
col_message <- function (..., col = 30, success = TRUE, verbose = !getOption("usethis.quiet", default = FALSE)){
  if(verbose){
    txt <- do.call(paste0, list(...))
    # Check if this function is called from within an rmarkdown document.
    # If that is the case, the colorized messages can cause knitting errors.
    if(!any(grepl("rmarkdown", unlist(lapply(sys.calls(), `[[`, 1)), fixed = TRUE))){
      if(success){
        cli::cli_bullets(text = c("v" = txt))
      } else {
        cli::cli_bullets(text = c("x" = txt))
      }
    }
  }
}
