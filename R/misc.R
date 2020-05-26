authors_from_csv <- function(filename, format = "papaja", what = "aut"){
  df <- read.csv(filename, stringsAsFactors = FALSE)
  if(!is.null(df[["order"]])) df <- df[order(df$order), -which(names(df) == "order")]
  aff <- df[, grep("^X(\\.\\d{1,})?$", names(df))]

  unique_aff <- as.vector(t(as.matrix(aff)))
  unique_aff <- unique_aff[!unique_aff == ""]
  unique_aff <- unique_aff[!duplicated(unique_aff)]
  df$affiliation <- apply(aff, 1, function(x){
    paste(which(unique_aff %in% unlist(x)), collapse = ",")
  })

  aff <- do.call(c, lapply(1:length(unique_aff), function(x){
    c(paste0("  - id: \"", x, "\""), paste0("    institution: \"", unique_aff[x], "\""))
  }))


  df$name <- paste(df[[1]], df[[2]])
  aut <- df[, c("name", "affiliation", "corresponding", "address", "email")]
  names(aut) <- paste0("    ", names(aut))
  names(aut)[1] <- "  - name"

  aut <- do.call(c, lapply(1:nrow(aut), function(x){
    tmp <- aut[x, ]
    tmp <- tmp[, !tmp == "", drop  = FALSE]
    out <- paste0(names(tmp), ': "', tmp, '"')
    gsub('\\"yes\\"', "yes", out)
  }))
  if(what == "aff") return(paste0(aff, collapse = "\n")) #cat("\n", aff, sep = "\n")

  if(what == "aut") return(paste0(aut, collapse = "\n")) #cat(aut, "", sep = "\n")

}

write_as_utf <- function(x, con, append = FALSE, encoding = "UTF-8", ...) {
  if(append){
    if(file.exists(con)){
      old_contents <- readLines(con, encoding = encoding)
      x <- c(old_contents, x)
    }
  }
  opts <- options(encoding = 'native.enc')
  on.exit(options(opts), add = TRUE)
  writeLines(enc2utf8(x), con, ..., useBytes = TRUE)
}

read_as_utf <- function(..., encoding = "UTF-8"){
  Args <- list(...)
  if(is.null(Args[["encoding"]])) Args[["encoding"]] <- encoding
  do.call(readLines, Args)
}

cran_version <- function(x = packageVersion("worcs")){
  tryCatch(
    gsub("(\\d+\\.\\d+\\.\\d+).*", "\\1", as.character(x), perl = TRUE),
    error = function(e){NA}
  )
}

