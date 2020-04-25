#' @importFrom gert libgit2_config git_config_global
has_git <- function(){
  config <- libgit2_config()
  settings <- git_config_global()
  name <- subset(settings, name == "user.name")$value
  email <- subset(settings, name == "user.email")$value
  (any(unlist(config[c("ssh", "https")])) & (length(name) && length(email)))
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
