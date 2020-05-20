get_workflow <- function(filename = "vignettes/workflow.Rmd"){
  txt <- readLines(filename)
  txt <- txt[grepl("<!--S:", txt, fixed = T)|grepl("^###", txt)]
  txt <- gsub("(<!--S: |-->.*$)", "", txt)
  txt
}

cat(get_workflow(), sep = "\n")
