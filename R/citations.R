#' Comprehensive citation Knit function for 'RStudio'
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, converting citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}, into normal
#' citations, e.g.: \code{@@reference2020}. Then, it renders the file.
#' @param inputFile The file passed to \code{\link[rmarkdown]{render}}.
#' @param encoding Ignored. The encoding is always assumed to be UTF-8.
#' @export
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effect of rendering an
#' \code{rmarkdown} file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an 'Rmarkdown' file, like so:
#' # knit: worcs::cite_all
#'
#' library(rmarkdown)
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), "citeall"))
#' setwd(file.path(tempdir(), "citeall"))
#' draft("test.Rmd", template = "github_document", package = "rmarkdown",
#'       create_dir = FALSE, edit = FALSE)
#' write(c("", "Optional reference: @@reference2020"),
#'       file = "test.Rmd", append = TRUE)
#' cite_all("test.Rmd", "UTF-8")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), "citeall"))
cite_all <- function(inputFile, encoding){
  Args <- list(
    inputFile = inputFile,
    encoding = encoding,
    citeall = TRUE
  )
  do.call(comprehensive_cite, Args)
}

#' Essential citations Knit function for 'RStudio'
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, removing citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}. Then, it renders
#' the file.
#' @param inputFile The file passed to \code{\link[rmarkdown]{render}}.
#' @param encoding Ignored. The encoding is always assumed to be UTF-8.
#' @export
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effect of rendering an
#' \code{rmarkdown} file.
#' @examples
#' # NOTE: Do not use this function interactively, as in the example below.
#' # Only specify it as custom knit function in an Rmarkdown file, like so:
#' # knit: worcs::cite_all
#'
#' library(rmarkdown)
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), "citeessential"))
#' setwd(file.path(tempdir(), "citeessential"))
#' draft("test.Rmd", template = "github_document", package = "rmarkdown",
#'       create_dir = FALSE, edit = FALSE)
#' write(c("", "Optional reference: @@reference2020"),
#'       file = "test.Rmd", append = TRUE)
#' cite_essential("test.Rmd", "UTF-8")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), "citeessential"))
cite_essential <- function(inputFile, encoding){
  Args <- list(
    inputFile = inputFile,
    encoding = encoding,
    citeall = FALSE
  )
  do.call(comprehensive_cite, Args)
}

#' @importFrom rmarkdown render
comprehensive_cite <- function(inputFile, encoding, citeall) {
  doc_text <- readLines(inputFile)
  bn <- basename(inputFile)
  if(citeall){
    writeLines(gsub("@@", "@", doc_text), bn)
  } else {
    writeLines(cleancitations(doc_text), bn)
  }
  Args <- list(
    input = bn,
    encoding = encoding
  )
  do.call(render, Args)
  writeLines(doc_text, bn)
  invisible(NULL)
}

cleancitations <- function(text){
  out <- paste0(text, collapse = "\n")
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
  gsub("\\s{0,1}\\[XXXXXDELETEMEXXXXX\\]", "", out) # The \\s might cause trouble
}
