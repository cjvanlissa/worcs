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
#' 'R Markdown' file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an 'R Markdown' file, like so:
#' # knit: worcs::cite_all
#'
#'  if (rmarkdown::pandoc_available("2.0")){
#'    if(requireNamespace("withr", quietly = TRUE)){
#'      withr::with_tempdir({
#'        file_name <- file.path("citeall.Rmd")
#'        loc <- rmarkdown::draft(file_name,
#'                                template = "github_document",
#'                                package = "rmarkdown",
#'                                create_dir = FALSE,
#'                                edit = FALSE)
#'        write(c("", "Optional reference: @@reference2020"),
#'              file = file_name, append = TRUE)
#'        cite_all(file_name)
#'      }, pattern = "cite_all")
#'    }
#'  }
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
#' 'R Markdown' file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an R Markdown file, like so:
#' # knit: worcs::cite_all
#'
#' if (rmarkdown::pandoc_available("2.0")){
#'   file_name <- tempfile("citeessential", fileext = ".Rmd")
#'   rmarkdown::draft(file_name,
#'                    template = "github_document",
#'                    package = "rmarkdown",
#'                    create_dir = FALSE,
#'                    edit = FALSE)
#'   write(c("", "Optional reference: @@reference2020"),
#'         file = file_name, append = TRUE)
#'   cite_essential(file_name)
#' }
cite_essential <- function(...){
  comprehensive_cite(..., citeall = FALSE)
}

#' @importFrom rmarkdown render pandoc_available
comprehensive_cite <- function(input, encoding = "UTF-8", ..., citeall = TRUE) {
  if(!pandoc_available("2.0")){
    message("Using rmarkdown requires pandoc version >= 2.0.")
    return(invisible(NULL))
  }
  dots <- list(...)
  dots$encoding <- encoding
  dots$input <- input
  doc_text <- readLines(input, encoding = encoding)
  if(citeall){
    write_as_utf(.nonessential_to_normal(doc_text), input)
  } else {
    write_as_utf(.remove_nonessential(doc_text), input)
  }
  do.call(render, dots)
  write_as_utf(doc_text, input) # reset file to original state
  invisible(NULL)
}

.nonessential_to_normal <- function(text){
  text <- gsub("(?<!`)@@", "@", text, perl = TRUE)
  text <- gsub("\\@\\@", "@@", text, fixed = TRUE)
  text
}

.remove_nonessential <- function(text){
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


# Extract citations
#
# This function extracts all citations from a character vector.
# @param txt Character vector, defaults to
# \code{readLines("manuscript/manuscript.Rmd")}.
# @param split Character vector to use for splitting, passed to
# \code{\link{strsplit}}.
# @param ... Additional arguments are passed to \code{\link{strsplit}}.
#@export
# @return Character vector.
# @examples
# extract_citations("This is just an example [@extract_cites; @works].")

extract_citations <- function(x = readLines("manuscript/manuscript.Rmd"),
                              split = "@+", ...){

  cl <- match.call()
  cl[[1L]] <- quote(strsplit)
  cl[["x"]] <- gsub("\\w@", "", paste0(x, collapse = ""))
  cl[["split"]] <- split
  cites <- eval(cl, envir = environment())[[1]][-1]
  cites <- gsub("^([a-zA-Z0-9-]+?)\\b.*$", "\\1", cites)
  tabcit <- as.data.frame.table(table(cites))
  tabcit[order(tabcit$Freq, decreasing = T), ]
}

string_citations <- function(x = readLines("manuscript/manuscript.Rmd"),
                              split = "@+", ...){

  cl <- match.call()
  cl[[1L]] <- quote(strsplit)
  cl[["x"]] <- gsub("\\w@", "", paste0(x, collapse = ""))
  cl[["split"]] <- split
  cites <- eval(cl, envir = environment())[[1]][-1]
  gsub("^([a-zA-Z0-9-]+?)\\b.*$", "\\1", cites)
}
