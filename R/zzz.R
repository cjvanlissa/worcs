# @importFrom rstudioapi versionInfo
.onAttach <- function(libname, pkgname) {
  #correct_version <- versionInfo()$version >= "1.1.28"
  print_message <- "Welcome to WORCS: Workflow for Open Reproducible Code in Science. Please read the tutorial before using this package, and consider citing it: Van Lissa and colleagues (2020) <doi:10.17605/OSF.IO/ZCVBS>."
  if(!has_git()){
    print_message <- paste0(print_message, "\nCould not find a working installation of 'Git', which is required to safeguard the transparency and reproducibility of your project. Please connect 'Git' by following the steps described in this vignette:\n  vignette('setup', package = 'worcs')")
  }
  #if(!correct_version){ "Rstudio version 1.1.28 or higher is required to use the worcs package."))
  packageStartupMessage(print_message)
}
