get_aut(what){
  filename = "authors.csv"
  df <- read.csv(filename, stringsAsFactors = FALSE)
  if(!is.null(df[["order"]])) df <- df[order(df$order), -which(names(df) == "order")]
  aff <- df[, grep("^X(\\.\\d{1,})?$", names(df))]
  unique_aff <- as.vector(t(as.matrix(aff)))
  unique_aff <- unique_aff[!unique_aff == ""]
  unique_aff <- unique_aff[!duplicated(unique_aff)]
  df$affiliation <- apply(aff, 1, function(x){
    paste(letters[which(unique_aff %in% unlist(x))], collapse = ",")
  })

  aff <- paste0(letters[1:length(unique_aff)], ": ", unique_aff, collapse = "\n")

  df$name <- paste(df[[1]], df[[2]])
  aut <- df[, c("name", "affiliation", "corresponding", "address", "email")]

  aut <- paste0(aut$name, "\\$\\^\\{", aut$affiliation, "\\}\\$", collapse = '\n')
  if(what == "aff"){
    cat(aff)
  } else {
    browser()
    cat(aut)
  }
}
