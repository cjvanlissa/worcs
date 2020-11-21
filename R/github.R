#' @title Modify .gitignore file
#' @description Arguments passed through \code{...} are added to the .gitignore
#' file. Elements already present in the file are modified.
#' When \code{ignore = TRUE}, the arguments are added to the .gitignore file,
#' which will cause 'Git' to not track them.
#'
#' When \code{ignore = FALSE}, the arguments are prepended with \code{!},
#' This works as a "double negation", and will cause 'Git' to track the files.
#' @param ... Any number of character arguments, representing files to be added
#' to the .gitignore file.
#' @param ignore Logical. Whether or not 'Git' should ignore these files.
#' @param repo a path to an existing repository, or a git_repository object as
#' returned by git_open, git_init or git_clone.
#' @return No return value. This function is called for its side effects.
#' @rdname git_ignore
#' @examples
#' dir.create(".git")
#' git_ignore("ignorethis.file")
#' unlink(".git", recursive = TRUE)
#' file.remove(".gitignore")
#' @export
git_ignore <- function(..., ignore = TRUE, repo = "."){
  ab_path <- normalizePath(repo)
  if(!dir.exists(file.path(ab_path, ".git"))){
    stop("No valid Git repository exists at ", normalizePath(file.path(ab_path, ".git")), call. = FALSE)
  }
  dots <- unlist(list(...))
  path_gitig <- file.path(ab_path, ".gitignore")
  cl <- match.call()
  cl[[1L]] <- str2lang("worcs:::write_gitig")
  cl[["filename"]] <- path_gitig
  cl[c("ignore", "repo")] <- NULL
  cl[["modify"]] <- file.exists(path_gitig)
  if(!ignore){
    ig_these <- names(cl) == "" & sapply(cl, class) == "character"
    if(any(ig_these)){
      cl[ig_these] <- lapply(cl[ig_these], function(x){ paste0("!", x) })
    }
  }
  eval(cl, parent.frame())
}

#' @importFrom gert libgit2_config git_config_global
has_git <- function(){
  tryCatch({
    config <- libgit2_config()
    return(has_git_user() & (any(unlist(config[c("ssh", "https")]))))
  }, error = function(e){
    return(FALSE)
  })
}

#' @title Set global 'Git' credentials
#' @description This function is a wrapper for
#' \code{\link[gert:git_config]{git_config_global_set}}.
#' It sets two name/value pairs at
#' once: \code{name = "user.name"} is set to the value of the \code{name}
#' argument, and \code{name = "user.email"} is set to the value of the
#' \code{email} argument.
#' @param name Character. The user name you want to use with 'Git'.
#' @param email Character. The email address you want to use with 'Git'.
#' @param overwrite Logical. Whether or not to overwrite existing 'Git'
#' credentials. Use this to prevent code from accidentally overwriting existing
#' 'Git' credentials. The default value uses \code{\link{has_git_user}}
#' to set overwrite to \code{FALSE} if user credentials already exist, and to
#' \code{TRUE} if no user credentials exist.
#' @param verbose Logical. Whether or not to print status messages to
#' the console. Default: TRUE
#' @return No return value. This function is called for its side effects.
#' @rdname git_user
#' @examples
#' do.call(git_user, worcs:::get_user())
#' @export
#' @importFrom gert git_config_global_set
git_user <- function(name, email, overwrite = !has_git_user(), verbose = TRUE){
  if(overwrite){
    invisible(
      tryCatch({
        do.call(git_config_global_set, list(
          name = "user.name",
          value = name
        ))
        do.call(git_config_global_set, list(
          name = "user.email",
          value = email
        ))
        col_message("'Git' username set to '", name, "' and email set to '", email, "'.", verbose = verbose)
      }, error = function(e){col_message("Could not set 'Git' credentials.", success = FALSE)})
    )
  } else {
    message("To set the 'Git' username and email, call 'git_user()' with the argument 'overwrite = TRUE'.")
  }
}

#' @importFrom gert git_config_global
get_user <- function(){
  Args <- list(
    name = "yourname",
    email = "yourname@email.com"
  )
  if(has_git_user()){
    cf <- git_config_global()
    Args$name <- cf$value[cf$name == "user.name"]
    Args$email <- cf$value[cf$name == "user.email"]
  }
  return(Args)
}

#' @title Check whether global 'Git' credentials exist
#' @description Check whether the values \code{user.name} and \code{user.email}
#' exist exist in the 'Git' global configuration settings.
#' Uses \code{\link[gert:git_config]{git_config_global}}.
#' @return Logical, indicating whether 'Git' global configuration settings could
#' be retrieved, and contained the values
#' \code{user.name} and \code{user.email}.
#' @rdname has_git_user
#' @examples
#' has_git_user()
#' @export
#' @importFrom gert git_config_global
has_git_user <- function(){
  tryCatch({
    cf <- git_config_global()
    if(!("user.name" %in% cf$name) & ("user.email" %in% cf$name)){
      stop()
    } else {
      return(TRUE)
    }
  }, error = function(e){
    message("No 'Git' credentials found, returning name = 'yourname' and email = 'yourname@email.com'.")
    return(FALSE)
  })
}

#' @title Add, commit, and push changes.
#' @description This function is a wrapper for
#' \code{\link[gert:git_add]{git_add}}, \code{\link[gert:git_commit]{git_commit}},
#' and
#' \code{\link[gert:git_push]{git_push}}. It adds all locally changed files to the
#' staging area of the local 'Git' repository, then commits these changes
#' (with an optional) \code{message}, and then pushes them to a remote
#' repository. This is used for making a "cloud backup" of local changes.
#' Do not use this function when working with privacy sensitive data,
#' or any other file that should not be pushed to a remote repository.
#' The \code{\link[gert:git_add]{git_add}} argument
#' \code{force} is disabled by default,
#' to avoid accidentally committing and pushing a file that is listed in
#' \code{.gitignore}.
#' @param remote name of a remote listed in git_remote_list()
#' @param refspec string with mapping between remote and local refs
#' @param password a string or a callback function to get passwords for authentication or password protected ssh keys. Defaults to askpass which checks getOption('askpass').
#' @param ssh_key	path or object containing your ssh private key. By default we look for keys in ssh-agent and credentials::ssh_key_info.
#' @param verbose display some progress info while downloading
#' @param repo a path to an existing repository, or a git_repository object as returned by git_open, git_init or git_clone.
#' @param mirror use the --mirror flag
#' @param force use the --force flag
#' @param files vector of paths relative to the git root directory. Use "." to stage all changed files.
#' @param message a commit message
#' @param author A git_signature value, default is git_signature_default.
#' @param committer A git_signature value, default is same as author
#' @return No return value. This function is called for its side effects.
#' @examples
#' git_update()
#' @rdname git_update
#' @export
#' @importFrom gert git_config_global_set git_ls git_add git_commit git_push
git_update <- function(message = paste0("update ", Sys.time()),
                       files = ".",
                       repo = ".",
                       author,
                       committer,
                       remote,
                       refspec,
                       password,
                       ssh_key,
                       mirror,
                       force,
                       verbose = TRUE){
  tryCatch({
    git_ls(repo)
    col_message("Identified local 'Git' repository.", verbose = verbose)
  }, error = function(e){
    col_message("Not a 'Git' repository.", success = FALSE)
    col_message("Could not add files to staging area of 'Git' repository.", success = FALSE)
    col_message("Could not commit staged files to 'Git' repository.", success = FALSE)
    col_message("Could not push local commits to remote repository.", success = FALSE)
    return()
    })

  cl <- as.list(match.call()[-1])
  for(this_arg in c("message", "files", "repo")){
    if(is.null(cl[[this_arg]])){
      cl[[this_arg]] <- formals()[[this_arg]]
    }
  }
  #if(length(cl) > 0){
  #  Args[sapply(names(cl), function(i) which(i == names(Args)))] <- cl
  #}

  Args_add <- cl[names(cl) %in% c("files", "repo")]
  Args_commit <- cl[names(cl) %in% c("message", "author", "committer", "repo")]
  Args_push <- cl[names(cl) %in% c("remote", "refspec", "password", "ssh_key", "mirror", "force", "verbose", "repo")]
  invisible(
    tryCatch({
      do.call(git_add, Args_add)
      col_message("Added files to staging area of 'Git' repository.", verbose = verbose)
    }, error = function(e){col_message("Could not add files to staging area of 'Git' repository.", success = FALSE)})
  )
  invisible(
    tryCatch({
      do.call(git_commit, Args_commit)
      col_message("Committed staged files to 'Git' repository.", verbose = verbose)
    }, error = function(e){col_message("Could not commit staged files to 'Git' repository.", success = FALSE)})
  )
  invisible(
    tryCatch({
      do.call(git_push, Args_push)
      col_message("Pushed local commits to remote repository.", verbose = verbose)
    }, error = function(e){col_message("Could not push local commits to remote repository.", success = FALSE)})
  )
}


parse_repo <- function(remote_repo, verbose = TRUE){
  valid_repo <- grepl("^git@.+?\\..+?:.+?/.+?(\\.git)?$", remote_repo) | grepl("^https://.+?\\..+?/.+?/.+?(\\.git)?$", remote_repo)
  if(!valid_repo){
    col_message("Not a valid 'Git' remote repository address: ", remote_repo, success = FALSE, verbose = verbose)
    return(NULL)
  }
  repo_url <- gsub("(^.+?@)(.*)$", "\\2", remote_repo)
  repo_url <- gsub("(\\..+?):", "\\1/", repo_url)
  repo_url <- gsub("\\.git$", "", repo_url)
  gsub("^(https://)?", "https://", repo_url)
}
