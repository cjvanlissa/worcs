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
comprehensive_cite <- function(input, ..., citeall = TRUE) {
  dots <- list(...)

  doc_text <- readLines(input)
  temp <- paste0(tempdir(), "/", basename(input))
  if(citeall){
    writeLines(gsub("@@", "@", doc_text), temp)
  } else {
    writeLines(cleancitations(doc_text), temp)
  }
  dir <- dirname(input)
  dots$input <- temp
  dots$output_dir <- dir
  do.call(render, dots)
  invisible(NULL)
}

cleancitations <- function(text){
  out <- paste0(c(text, " onzin"), collapse = "\n")
  out <- as.list(strsplit(out, "\\[")[[1]])
  out <- lapply(out, function(x){
    if(grepl("@@", x)){
      ref_sec <- unlist(strsplit(x, split = "\\]"))
      if(length(ref_sec) > 1){
        if(grepl("@@", ref_sec[1])){
          each_ref_sec <- unlist(strsplit(ref_sec[1], split = ";"))
          ref_sec[1] <- paste0(each_ref_sec[!grepl("@@", each_ref_sec)], collapse = ";")
          if(ref_sec[1] == "") ref_sec[1] <- "XXXXXDELETEMEXXXXX"
        }
        if(grepl("@@", ref_sec[2])){
          ref_sec[2] <- gsub(" -?@@.+? ", " ", ref_sec[2])
        }
      } else {
        ref_sec[1] <- gsub(" -?@@.+? ", " ", ref_sec[1])
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
