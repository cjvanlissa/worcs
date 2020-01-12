# @importFrom rstudioapi versionInfo
.onAttach <- function(libname, pkgname) {
  #correct_version <- versionInfo()$version >= "1.1.28"
  print_message <- paste0("Welcome to WORCS: Worflow for Open Reproducible Code in Science. Please read the tutorial before using this package, and consider citing it. ",
                          ifelse(has_git(), "",
                                 "Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.")
                          #, ifelse(correct_version, "Haaai", "Rstudio version 1.1.28 or higher is required to use the worcs package.")
  )
  packageStartupMessage(print_message)
}
