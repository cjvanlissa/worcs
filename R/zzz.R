.onAttach <- function(libname, pkgname) {
  has_git <- system(command = "git") == 1
  print_message <- paste0("Before using the worcs package, make sure to read the accompanying tutorial. Please cite the tutorial in publications. ",
                          ifelse(has_git, "",
                                 "Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.")
  )
  packageStartupMessage(print_message)
}
