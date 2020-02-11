#' @importFrom gert libgit2_config git_config_global
has_git <- function(){
  config <- libgit2_config()
  settings <- git_config_global()
  name <- subset(settings, name == "user.name")$value
  email <- subset(settings, name == "user.email")$value
  hasit <- (any(unlist(config[c("ssh", "https")])) & (length(name) && length(email)))
  if(!hasit){
    warning("Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.", call. = FALSE)
  }
  hasit
}

#' @importFrom gert git_config_global_set
git_credentials <- function(name, email){
  invisible(
    tryCatch({
    git_config_global_set(name = "user.name", value = name)
    git_config_global_set(name = "user.email", value = email)
  }, error = function(e){warning("Could not set git credentials.", call. = FALSE)})
  )
}
