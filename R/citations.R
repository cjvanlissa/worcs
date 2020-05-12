#' Comprehensive citation Knit function for 'RStudio'
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, converting citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}, into normal
#' citations, e.g.: \code{@@reference2020}. Then, it renders the file.
#' @param ... All arguments are passed to \code{\link[rmarkdown]{render}}.
#' @export
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effect of rendering an
#' \code{rmarkdown} file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an 'Rmarkdown' file, like so:
#' # knit: worcs::cite_all
#'
#' file_name <- file.path(tempdir(), "citeall.Rmd")
#' loc <- rmarkdown::draft(file_name,
#'                         template = "github_document",
#'                         package = "rmarkdown",
#'                         create_dir = FALSE,
#'                         edit = FALSE)
#' write(c("", "Optional reference: @@reference2020"),
#'       file = file_name, append = TRUE)
#' cite_all(file_name)
cite_all <- function(...){
  comprehensive_cite(..., citeall = TRUE)
}

#' Essential citations Knit function for 'RStudio'
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, removing citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}. Then, it renders
#' the file.
#' @param ... All arguments are passed to \code{\link[rmarkdown]{render}}.
#' @export
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effect of rendering an
#' \code{rmarkdown} file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an Rmarkdown file, like so:
#' # knit: worcs::cite_all
#'
#' file_name <- tempfile("citeessential", fileext = ".Rmd")
#' rmarkdown::draft(file_name,
#'                  template = "github_document",
#'                  package = "rmarkdown",
#'                  create_dir = FALSE,
#'                  edit = FALSE)
#' write(c("", "Optional reference: @@reference2020"),
#'       file = file_name, append = TRUE)
#' cite_essential(file_name)
cite_essential <- function(...){
  comprehensive_cite(..., citeall = FALSE)
}

#' @importFrom rmarkdown render
comprehensive_cite <- function(input, encoding = "UTF-8", ..., citeall = TRUE) {
  dots <- list(...)
  dots$encoding <- encoding
  dots$input <- input
  doc_text <- readLines(input, encoding = encoding)
  if(citeall){
    write_as_utf(gsub("@@", "@", doc_text), input)
  } else {
    write_as_utf(cleancitations(doc_text), input)
  }
  do.call(render, dots)
  write_as_utf(doc_text, input) # reset file to original state
  invisible(NULL)
}

cleancitations <- function(text){
  out <- paste0(c(text, " onzin"), collapse = "\n")
  out <- as.list(strsplit(out, "[", fixed = TRUE)[[1]])
  out <- lapply(out, function(x){
    if(grepl("@@", x, fixed = TRUE)){
      ref_sec <- unlist(strsplit(x, split = "]", fixed = TRUE))
      if(length(ref_sec) > 1){
        if(grepl("@@", ref_sec[1], fixed = TRUE)){
          each_ref_sec <- unlist(strsplit(ref_sec[1], split = ";"))
          ref_sec[1] <- paste0(each_ref_sec[!grepl("@@", each_ref_sec, fixed = TRUE)], collapse = ";")
          if(ref_sec[1] == "") ref_sec[1] <- "XXXXXDELETEMEXXXXX"
        }
        if(grepl("@@", ref_sec[2], fixed = TRUE)){
          ref_sec[2] <- gsub("\\s{0,1}-?@@.+?\\b\\s{0,1}", " ", ref_sec[2])
        }
      } else {
        ref_sec[1] <- gsub("\\s{0,1}-?@@.+?\\b\\s{0,1}", " ", ref_sec[1])
      }
      paste0(ref_sec, collapse = "]")
    } else {
      x
    }
  })
  out <- paste0(unlist(out), collapse = "[")
  out <- gsub("\\s{0,1}\\[XXXXXDELETEMEXXXXX\\]", "", out) # The \\s might cause trouble
  substr(out, 1, nchar(out)-6)
}
