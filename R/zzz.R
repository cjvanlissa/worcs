# @importFrom rstudioapi versionInfo
.onAttach <- function(libname, pkgname) {
  #correct_version <- versionInfo()$version >= "1.1.28"
  print_message <- "\033[0;34mWelcome to WORCS: Workflow for Open Reproducible Code in Science. Please read the tutorial before using this package, and consider citing it:\n  Van Lissa and colleagues (2020) <doi:10.3233/DS-210031>\033[0m"
  if(!has_git()){
    print_message <- paste0(print_message, "\n\033[0;31mCould not find a working installation of 'Git', which is required to safeguard the transparency and reproducibility of your project. Please connect 'Git' by following the steps described in this vignette:\n  vignette('setup', package = 'worcs')\033[0m")
  }
  #if(!correct_version){ "RStudio version 1.1.28 or higher is required to use the worcs package."))
  packageStartupMessage(print_message)
}
