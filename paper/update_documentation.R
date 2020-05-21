txt <- readLines("vignettes/workflow.Rmd")
txt <- txt[grepl("<!--S:", txt, fixed = T)|grepl("^###", txt)]
txt <- gsub("(<!--S: |-->.*$)", "", txt)
txt <- gsub("^#", "", txt)
out <- vector("character")
for(i in seq_along(txt)){
  if(startsWith(txt[i], "#")){
    out <- append(out, c("", txt[i], ""))
  } else {
    out <- append(out, txt[i])
  }
}

readme <- readLines("inst/rstudio/templates/project/resources/README.md")
readme <- readme[-c(which(startsWith(readme, "## WORCS: Steps to follow for a project"))+1:length(readme))]
readme <- append(readme, out)

worcs:::write_as_utf(readme, "inst/rstudio/templates/project/resources/README.md")

reorder_numbers <- function(txt = readClipboard()){
  num_line <- which(grepl("^\\d{1,}\\.", txt))
  for(i in seq_along(num_line)){
    this_line <- txt[num_line[i]]
    the_num <- as.numeric(strsplit(this_line, "\\.")[[1]][1])
    if(!the_num == i){
      txt[num_line[i]] <- gsub(paste0("^", the_num), i, txt[num_line[i]])
    }
  }
  txt
}
cat(get_workflow(), sep = "\n")

reorder_numbers()
