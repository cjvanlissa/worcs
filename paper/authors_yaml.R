df <- read.csv("paper/authors.csv")

Caspar J. van Lissa\\
Utrecht University\\
Padualaan 14, 3584CH Utrecht, The Netherlands\\
E-mail: \href{mailto:c.j.vanlissa@uu.nl}{\nolinkurl{c.j.vanlissa@uu.nl}}\\
out <- vector("character")
for(i in 1:nrow(df)){
  this_aut <- df[i, ]
  addthis <- paste0(c(
    name = paste(this_aut["first"], this_aut["last"]),
    affiliation = gsub(", ", "\n", paste0(this_aut[grepl("^X(\\.\\d)?$", names(this_aut))], collapse = "; "), fixed = TRUE),
    address = tryCatch(unname(this_aut["address"]), error = function(e){""}),
    email = paste0("\\href{mailto:", this_aut["email"], "}{\\nolinkurl{", this_aut["email"], "}}")
  )[!this_aut[c("first", "X", "address", "email")] == ''], collapse = "\\\\\n")
  out <- paste0(out, addthis, sep = "\\\\\\\\\n")
}
cat(out)


aut <- lapply(1:nrow(df), function(i){
  #i=1
  this_aut <- df[i, ]
  out <- c(
    name = paste(this_aut["first"], this_aut["last"]),
    affiliation = paste0(this_aut[grepl("^X(\\.\\d)?$", names(this_aut))], collapse = "; "),
    address = tryCatch(unname(this_aut["address"]), error = function(e){""}),
    email = unname(this_aut["email"])
  )
  out[!out==""]
})

cat(yaml::as.yaml(aut))
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
