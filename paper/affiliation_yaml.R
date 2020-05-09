df <- read.csv("paper/authors.csv")

aff <- df[, 6:ncol(df)]

unique_aff <- as.vector(t(as.matrix(aff)))
unique_aff <- unique_aff[!unique_aff == ""]
unique_aff <- unique_aff[!duplicated(unique_aff)]

aff <- do.call(c, lapply(1:length(unique_aff), function(x){
  c(paste0("  - id: \"", x, "\""), paste0("    institution: \"", unique_aff[x], "\""))
}))

cat("\n", aff, sep = "\n")
