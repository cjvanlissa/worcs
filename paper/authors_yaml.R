df <- read.csv("paper/authors.csv")

aff <- df[, 6:ncol(df)]

unique_aff <- as.vector(t(as.matrix(aff)))
unique_aff <- unique_aff[!unique_aff == ""]
unique_aff <- unique_aff[!duplicated(unique_aff)]

df$institution <- apply(aff, 1, function(x){
  paste(which(unique_aff %in% unlist(x)), collapse = ",")
})
df$name <- paste(df[[1]], df[[2]])
names(df)
aut <- df[, c("name", "institution", "corresponding", "address", "email")]
names(aut) <- paste0("    ", names(aut))
names(aut)[1] <- "  - name"

aut <- do.call(c, lapply(1:nrow(aut), function(x){
  tmp <- aut[x, ]
  tmp <- tmp[, !tmp == "", drop  = FALSE]
  out <- paste0(names(tmp), ': "', tmp, '"')
  gsub('\\"yes\\"', "yes", out)
}))
print(cat("\n", aut, "", sep = "\n"))
cat("\n", aut, "", sep = "\n")
