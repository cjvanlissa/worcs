#' @importFrom git2r default_signature
has_git <- function(){
  out <- system("git", ignore.stdout = TRUE) == 1
  if(!out){
    warning("Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.", call. = FALSE)
  }
  out
}
