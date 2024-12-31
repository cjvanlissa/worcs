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
git_ignore <- function(..., ignore = TRUE, repo = ".") {
  ab_path <- normalizePath(repo)
  if (!dir.exists(file.path(ab_path, ".git"))) {
    stop("No valid Git repository exists at ",
         normalizePath(file.path(ab_path, ".git")),
         call. = FALSE)
  }
  dots <- unlist(list(...))
  path_gitig <- file.path(ab_path, ".gitignore")
  cl <- match.call()
  cl[[1L]] <- str2lang("worcs:::write_gitig")
  cl[["filename"]] <- path_gitig
  cl[c("ignore", "repo")] <- NULL
  cl[["modify"]] <- file.exists(path_gitig)
  if (!ignore) {
    ig_these <- names(cl) == "" & sapply(cl, class) == "character"
    if (any(ig_these)) {
      cl[ig_these] <- lapply(cl[ig_these], function(x) {
        paste0("!", x)
      })
    }
  }
  eval(cl, parent.frame())
}

#' @importFrom gert libgit2_config git_config_global
has_git <- function() {
  tryCatch({
    config <- libgit2_config()
    return(has_git_user() &
             (any(unlist(config[c("ssh", "https")]))))
  }, error = function(e) {
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
git_user <- function(name,
                     email,
                     overwrite = !has_git_user(),
                     verbose = TRUE) {
  if (overwrite) {
    invisible(tryCatch({
      do.call(git_config_global_set,
              list(name = "user.name", value = name))
      do.call(git_config_global_set,
              list(name = "user.email", value = email))
      col_message("'Git' username set to '",
                  name,
                  "' and email set to '",
                  email,
                  "'.",
                  verbose = verbose)
    }, error = function(e) {
      col_message("Could not set 'Git' credentials.", success = FALSE)
    }))
  } else {
    message(
      "To set the 'Git' username and email, call 'git_user()' with the argument 'overwrite = TRUE'."
    )
  }
}

#' @importFrom gert git_config_global
get_user <- function() {
  Args <- list(name = "yourname", email = "yourname@email.com")
  if (has_git_user()) {
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
has_git_user <- function() {
  tryCatch({
    cf <- git_config_global()
    if (!("user.name" %in% cf$name) & ("user.email" %in% cf$name)) {
      stop()
    } else {
      return(TRUE)
    }
  }, error = function(e) {
    message(
      "No 'Git' credentials found, returning name = 'yourname' and email = 'yourname@email.com'."
    )
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
                       verbose = TRUE) {
  cl <- match.call.defaults()

  tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Identify local 'Git' repository at {.val {repo}}")
    git_ls(repo = repo)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })

  cl_add <- cl[c(1L, which(names(cl) %in% c("files", "repo")))]
  cl_add[[1L]] <- str2lang("gert::git_add")
  cl_commit <- cl[c(1L, which(names(cl) %in% c(
    "message", "author", "committer", "repo"
  )))]
  cl_commit[[1L]] <- str2lang("gert::git_commit")
  cl_push <- cl[c(1L, which(
    names(cl) %in% c(
      "remote",
      "refspec",
      "password",
      "ssh_key",
      "mirror",
      "force",
      "verbose",
      "repo"
    )
  ))]
  cl_push[[1L]] <- str2lang("gert::git_push")

  invisible(tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Adding files to staging area of 'Git' repository.")
    eval.parent(cl_add)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  }))

  invisible(tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Committed staged files to 'Git' repository.")
    eval.parent(cl_commit)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  }))

  tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Push local commits to remote repository.")
    eval.parent(cl_push)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })
  invisible()
}



parse_repo <- function(remote_repo, verbose = TRUE) {
  valid_repo <- grepl("^git@.+?\\..+?:.+?/.+?(\\.git)?$", remote_repo) |
    grepl("^https://.+?\\..+?/.+?/.+?(\\.git)?$", remote_repo)
  if (!valid_repo) {
    col_message(
      "Not a valid 'Git' remote repository address: ",
      remote_repo,
      success = FALSE,
      verbose = verbose
    )
    return(NULL)
  }
  repo_url <- gsub("(^.+?@)(.*)$", "\\2", remote_repo)
  repo_url <- gsub("(\\..+?):", "\\1/", repo_url)
  repo_url <- gsub("\\.git$", "", repo_url)
  gsub("^(https://)?", "https://", repo_url)
}

#' @title Create a New 'GitHub' Repository
#' @description Given that a 'GitHub' user is configured, with the appropriate
#' permissions, this function creates a new repository on your account.
#' @param name Name of the repository to be created.
#' @param private Whether or not the repository should be private, defaults to
#' `FALSE`.
#' @return Invisibly returns a logical value,
#' indicating whether the function was successful or not.
#' @examples
#' git_remote_create()
#' @rdname git_remote_create
#' @export
#' @importFrom cli cli_process_start cli_process_done cli_process_failed
#' @importFrom gh gh gh_whoami
git_remote_create <- function(name, private = TRUE) {
  git_usrnm <- tryCatch(
    gh::gh_whoami()$login,
    error = function(e) {
      "username"
    }
  )
  with_cli_try("Creating GitHub repository '{git_usrnm}/{name}'", {
    if (git_usrnm == "username")
      stop()
    if (private) {
      invisible(gh::gh("POST /user/repos", name = name, private = "true"))
    } else {
      invisible(gh::gh("POST /user/repos", name = name))
    }
  })
}

# These are all used in git_release_publish below:
#' @importFrom utils getFromNamespace
target_repo <- utils::getFromNamespace("target_repo", "usethis")
check_can_push <- utils::getFromNamespace("check_can_push", "usethis")
get_release_data <- utils::getFromNamespace("get_release_data", "usethis")
gh_tr <- utils::getFromNamespace("gh_tr", "usethis")
check_github_has_SHA <- utils::getFromNamespace("check_github_has_SHA", "usethis")
# To here

#' @title Publish a Release on 'GitHub'
#' @description Given that a 'GitHub' user is configured, with the appropriate
#' permissions, this function pushes the current branch (if safe),
#' then publishes a 'GitHub' Release of the repository indicated by
#' `repo` to that user's account.
#' @param repo The path to the 'Git' repository.
#' @param tag_name Optional character string to specify the tag name. By
#' default, this is set to `NULL` and `git_release_publish()` uses version
#' numbers starting with `0.1.0` for both the `tag_name` and `release_name`
#' arguments. Override this behavior, for example, to increment the major
#' version number by specifying `0.2.0`.
#' @param release_name Optional character string to specify the tag name. By
#' default, this is set to `NULL` and `git_release_publish()` uses version
#' numbers starting with `0.1.0` for both the `tag_name` and `release_name`
#' arguments. Override this behavior, for example, to increment the major
#' version number by specifying `0.2.0`.
#' @return No return value. This function is called for its side effects.
#' @examples
#' \dontrun{
#' git_release_publish()
#' }
#' @rdname git_remote_create
#' @export
#' @importFrom cli cli_process_start cli_process_done cli_process_failed
#' @importFrom gh gh gh_whoami
#' @importFrom usethis with_project
git_release_publish <- function(repo = ".",
                                tag_name = NULL,
                                release_name = NULL) {
  tryCatch({
    cli::cli_process_start("Posting release to GitHub")
    usethis::with_project(repo, code = {
      tr <- target_repo(github_get = TRUE,
                        ok_configs = c("ours", "fork"))
    }, quiet = TRUE)
    usethis::with_project(repo, code = {
      check_can_push(tr = tr, "to create a release")
    }, quiet = TRUE)
    usethis::with_project("c:/git_repositories/worcs",
                          code = {
                            dat <- get_release_data(tr)
                          },
                          quiet = TRUE)

    # Get current commit hash
    SHA = gert::git_info(repo = repo)$commit
    gh <- gh_tr(tr)
    # Determine version
    if (is.null(tag_name)) {
      releases <- gh("GET /repos/{owner}/{repo}/releases")
      tag_last_release <- try(releases[[1]][["tag_name"]], silent = TRUE)
      if (inherits(tag_last_release, what = "try-error")) {
        tag_name <- "0.1.0"
      } else {
        tag_integer <- unclass(package_version(tag_last_release))[[1]]
        tag_integer[3] <- tag_integer[3] + 1
        tag_name <- paste(tag_integer, collapse = ".")
      }
    }
    if (is.null(release_name))
      release_name <- tag_name

    gert::git_push(verbose = FALSE)

    check_github_has_SHA(SHA = SHA, tr = tr)

    release <- gh(
      "POST /repos/{owner}/{repo}/releases",
      name = release_name,
      tag_name = tag_name,
      target_commitish = SHA,
      draft = FALSE
    )
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })
  invisible()
}

git_remote_delete <- function(repo) {
  tryCatch({
    cli::cli_process_start("Deleting remote repository")
    ownr <- gh::gh_whoami()$login
    test_repo <- gert::git_remote_ls(remote = paste0("https://github.com/", ownr, "/", repo))
    if (!inherits(test_repo, "data.frame"))
      stop()
    paste0("DELETE /repos/{owner}/{repo}")
    gh("DELETE /repos/{owner}/{repo}",
       owner = ownr,
       repo = repo)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })
  invisible()
}


git_connect_or_create <- function(repo, remote_repo) {
  # Connect to remote repo if possible
  if (is.null(remote_repo)) {
    cli_msg("i" = "Argument {.val remote_repo} is {.val NULL}; you are working with a local repository only.")
    stop()
  } else {
    ownr <- gh::gh_whoami()$login
    repo_name <- paste0(ownr, "/", remote_repo)
    repo_url <- paste0("https://github.com/", repo_name)
    test_repo <- try(gert::git_remote_ls(remote = repo_url), silent = TRUE)
    repo_exists <- isFALSE(inherits(test_repo, "try-error"))
    if (!repo_exists) {
      git_remote_create(remote_repo, private = FALSE)
    }
    git_remote_connect(repo = repo, remote_repo = remote_repo)
  }
  git_remote_test(repo = repo)
}


#' @title Connect to Existing 'GitHub' Repository
#' @description Given that a 'GitHub' user is configured, with the appropriate
#' permissions, this function connects to an existing repository.
#' @inheritParams git_update
#' @param remote_repo Character, indicating the name of a repository on your
#' account.
#' @return Invisibly returns a list with the following elements:
#'
#' * repo_url: Character, URL of the connected repository
#' * repo_exists: Logical
#' * prior_commits: Logical
#'
#' @examples
#' \dontrun{
#' git_remote_connect()
#' }
#' @rdname git_remote_connect
#' @export
#' @seealso
#'  \code{\link[gh]{gh_whoami}}
#'  \code{\link[gert]{git_fetch}}, \code{\link[gert]{git_remote}}
#' @export
#' @importFrom gh gh_whoami
#' @importFrom gert git_remote_ls git_remote_add
git_remote_connect <- function(repo, remote_repo) {
  # Connect to remote repo if possible
  with_cli_try("Connecting to remote repository {.val {remote_repo}}", {
    if (is.null(remote_repo))
      stop()

    ownr <- gh::gh_whoami()$login
    repo_name <- paste0(ownr, "/", remote_repo)
    repo_url <- paste0("https://github.com/", repo_name)
    test_repo <- try(gert::git_remote_ls(remote = repo_url), silent = TRUE)
    repo_exists <- isFALSE(inherits(test_repo, "try-error"))
    if (!repo_exists)
      stop()
    if (nrow(test_repo) > 0) {
      cli_msg("i" = "Remote repository already exists and has previous commits. Connect manually to avoid merge conflicts.")
      stop()
    }
    Args_gert <- list(name = "origin",
                      url = repo_url,
                      repo = repo)
    do.call(gert::git_remote_add, Args_gert)

  })
  return(git_remote_test(repo))
}

git_remote_test <- function(repo) {
  # Tests
  test_repo <- try(gert::git_remote_list(repo = repo), silent = TRUE)
  repo_url <- tryCatch(test_repo$url[1], error = function(e){""})
  repo_exists <- isTRUE(try(grepl("^https", repo_url), silent = TRUE))

  if (repo_exists) {
    prior_commits <- try(gert::git_remote_ls(remote = test_repo$url[1]), silent = TRUE)
    prior_commits <- isFALSE(nrow(prior_commits) == 0)
  } else {
    prior_commits <- FALSE
  }
  invisible(return(
    list(
      repo_url = repo_url,
      repo_exists = repo_exists,
      prior_commits = prior_commits
    )
  ))
}
