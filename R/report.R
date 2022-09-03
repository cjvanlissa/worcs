#' Report formatted number
#'
#' Report a number, rounded to a specific number of decimals (defaults to two),
#' using \code{\link{formatC}}. Intended for 'R Markdown' reports.
#' @param x Numeric. Value to be reported
#' @param digits Integer. Number of digits to round to.
#' @param equals Logical. Whether to report an equals (or: smaller than) sign.
#' @return An atomic character vector.
#' @author Caspar J. van Lissa
#' @keywords internal
#' @export
#' @examples
#' report(.0234)
report <- function(x, digits = 2, equals = TRUE){
  equal_sign <- "= "
  if(x%%1==0){
    outstring <- format_with_na(x, digits = 0, format = "f")
  } else {
    if(abs(x) <  10^-digits){
      equal_sign <- "< "
      outstring <- 10^-digits
    } else {
      outstring <- format_with_na(x, digits = digits, format = "f")
    }
  }
  ifelse(equals, paste0(equal_sign, outstring), outstring)
}

format_with_na <- function(x, ...){
  cl <- match.call()
  missings <- is.na(x)
  out <- rep(NA, length(x))
  cl$x <- na.omit(x)
  cl[[1L]] <- quote(formatC)
  out[!missings] <- eval.parent(cl)
  out
}
