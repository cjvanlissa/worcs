if(FALSE){

# Update manuscript templates ---------------------------------------------


library(rticles)
tem_rticles <- lsf.str("package:rticles")
tem_rticles <- tem_rticles[grep("_article", tem_rticles)]
library(papaja)
pap_rticles <- lsf.str("package:papaja")
file_content <- readLines("inst/rstudio/templates/project/worcs.dcf")
line_num <- grep("Fields:", file_content)[grep("Fields:", file_content) > grep("Parameter: manuscript", file_content)][1]
# current <- current[grep("Parameter: manuscript", current):grep("Parameter: preregistration", current)]
# current <- current[startsWith(current, "Fields:")]
current <- file_content[line_num]
current <- gsub("Fields: ", "", current, fixed = T)
current <- strsplit(current, ',')[[1]]
current <- trimws(current)

defaults <- c("github_document", "APA6", "None", "target_markdown")


file_content[line_num] <- paste0("Fields: ", paste0(c(defaults, tem_rticles), collapse = ", "))
writeLines(file_content, "inst/rstudio/templates/project/worcs.dcf")

descfile <- readLines("DESCRIPTION")
descfile[grep("rticles", descfile)] <- gsub("\\(>=(.+?)\\)", paste0("\\(>= ", packageVersion("rticles"), "\\)"), descfile[grep("rticles", descfile)])
writeLines(descfile, "DESCRIPTION")

# Update prereg templates -------------------------------------------------

library(prereg)
tem_prereg <- lsf.str("package:prereg")
tem_prereg <- tem_prereg[grep("_prereg", tem_prereg)]


file_content <- readLines("inst/rstudio/templates/project/worcs.dcf")
line_num <- grep("Fields:", file_content)[grep("Fields:", file_content) > grep("Parameter: preregistration", file_content)][1]
# current <- current[grep("Parameter: manuscript", current):grep("Parameter: preregistration", current)]
# current <- current[startsWith(current, "Fields:")]
current <- file_content[line_num]
current <- gsub("Fields: ", "", current, fixed = T)
current <- strsplit(current, ',')[[1]]
current <- trimws(current)

defaults <- c("None", "PSS", "Secondary")

file_content[line_num] <- paste0("Fields: ", paste0(c(defaults, tem_prereg), collapse = ", "))
writeLines(file_content, "inst/rstudio/templates/project/worcs.dcf")

descfile <- readLines("DESCRIPTION")
descfile[grep("prereg", descfile)] <- gsub("\\(>=(.+?)\\)", paste0("\\(>= ", packageVersion("prereg"), "\\)"), descfile[grep("prereg", descfile)])
writeLines(descfile, "DESCRIPTION")

}
