#' Comprehensive citation Knit function for RStudio
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, converting citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}, into normal
#' citations, e.g.: \code{@@reference2020}. Then, it renders the file.
#' @param inputFile The file passed to \code{\link[rmarkdown]{render}}.
#' @param encoding Ignored. The encoding is always assumed to be UTF-8.
#' @export
cite_all <- function(inputFile, encoding){
  Args <- list(
    inputFile = inputFile,
    encoding = encoding,
    citeall = TRUE
  )
  do.call(comprehensive_cite, Args)
}

#' Essential citations Knit function for RStudio
#'
#' This is a wrapper for \code{\link[rmarkdown]{render}}. First, this function
#' parses the citations in the document, removing citations
#' marked with double at sign, e.g.: \code{@@@@reference2020}.  Then, it renders
#' the file.
#' @param inputFile The file passed to \code{\link[rmarkdown]{render}}.
#' @param encoding Ignored. The encoding is always assumed to be UTF-8.
#' @export
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
  tmpfile <- gsub(bn, paste0("_compcite_", bn), inputFile)
  #tmpfile <- paste0("_compcite_", inputFile)
  if(citeall){
    writeLines(gsub("@@", "@", doc_text), tmpfile)
  } else {
    writeLines(cleancitations(doc_text), tmpfile)
  }
  Args <- list(
    input = tmpfile,
    encoding = encoding
  )
  do.call(render, Args)
  file.remove(tmpfile)
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
