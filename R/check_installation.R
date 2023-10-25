#' @title Check worcs dependencies
#' @description This function checks that all worcs dependencies are correctly
#' installed, and suggests how to remedy any missing dependencies.
#' @param what Character vector indicating which dependencies to check. Default:
#' `"all"`. All checks defined in the Usage section can be called, e.g.
#' `check_git` can be called using the argument `what = "git"`.
#' @return Logical, indicating whether all checks passed or not.
#' @examples
#' check_worcs_installation("none")
#' @rdname check_worcs_installation
#' @export
#' @importFrom gert user_is_configured libgit2_config git_init git_add git_commit
#' @importFrom credentials ssh_key_info
#' @importFrom tinytex pdflatex
#' @importFrom utils packageDescription
#' @importFrom gh gh_token
#' @importFrom renv consent
check_worcs_installation <- function(what = "all") {
  if (isTRUE(what == "none"))
    return(invisible(TRUE))
  pass <- list()
  errors <- list()
  checkfuns <- c("check_dependencies", "check_git", "check_github", "check_renv", "check_rmarkdown", "check_tinytext")

  # checkfuns <- ls(asNamespace("worcs"))
  # checkfuns <- checkfuns[startsWith(checkfuns, "check_")]
  # checkfuns <- setdiff(checkfuns, c("check_recursive", "check_sum", "check_worcs", "check_worcs_installation"))
  if(!what == "all"){
    checkfuns <- checkfuns[checkfuns %in% paste0("check_", what)]
    if(isFALSE(length(checkfuns) > 0)){
      stop("Argument 'what' does not refer to any valid checks.")
    }
  }
  out <- lapply(checkfuns, function(thisfun){
    out <- try(eval(str2lang(paste0("worcs::", thisfun, "()"))))
    if(inherits(out, "try-error")){
      out <- structure(list(pass = list(name = FALSE), errors = list()), class = c("worcs_check",
                                                                          "list"))
      names(out[["pass"]]) <- thisfun
    }
    out
    })

  worcs_checkres <- list(pass = do.call(c, lapply(out, `[[`, "pass")),
                         errors = do.call(c, lapply(out, `[[`, "errors")))
  class(worcs_checkres) <- c("worcs_check", class(worcs_checkres))
  return(invisible(isTRUE(all(pass))))
}

#' @rdname check_worcs_installation
#' @param package Atomic character vector, indicating for which package to check
#' the dependencies.
#' @export
check_dependencies <- function(package = "worcs") {
  available <- data.frame(installed.packages()) #[, c("Package", "Version")])
  thesedeps <- {
    pks <- packageDescription(package)
    if (isTRUE(is.na(pks))) pks <- vector("character")
    pks <- gsub("\n", "", pks$Imports, fixed = TRUE)
    pks <- gsub("\\s", "", pks)
    pks <- strsplit(pks, ",")[[1]]
    setdiff(
      pks,
      c(
        "R",
        "stats",
        "graphics",
        "grDevices",
        "utils",
        "datasets",
        "methods",
        "base",
        "tools"
      )
    )
  }
  has_version <- grepl("(", thesedeps, fixed = TRUE)
  correct_vers <- rep(TRUE, length(thesedeps))

  if(any(has_version)){
    vers <- data.frame(do.call(rbind, strsplit(thesedeps[has_version], "(", fixed = TRUE)))
    vers[,2] <- gsub(")", "", vers[,2], fixed = TRUE)
    vers$op <- gsub("[0-9\\.]", "", vers[,2])
    vers[,2] <- gsub("[^0-9.-]", "", vers[,2])
    thesedeps[has_version] <- vers[,1]
    correct_vers[has_version] <- sapply(vers$X1, function(n){
      tryCatch({
        do.call(vers$op[vers[[1]] == n], list(x = packageVersion(n), y = vers[1,2]))
        }, error = function(e){ FALSE })
    })
  }
  is_avlb <- thesedeps %in% available$Package
  if (all(is_avlb & correct_vers)) {
    out <- list(pass = list(dependencies = TRUE), errors = list(dependencies = ""))
  } else {
    errors <- thesedeps[which(!(is_avlb & correct_vers))]
    out <- list(
      pass = list(dependencies = FALSE),
      errors = list(
        dependencies = paste0(
          "The following packages are not installed (or their correct versions are not installed), run install.packages() for: ",
          paste0(errors, collapse = ", ")
        )
      )
    )
  }
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @export
check_git <- function() {
  pass <- list()
  errors <- list()
  # Check command line git
  pass[["git_cmd"]] <-
    system2("git",
            "--version",
            stdout = tempfile(),
            stderr = tempfile()) == 0L
  if (!pass[["git_cmd"]])
    errors[["git_cmd"]] <-
    "Could not execute Git on the command line; please reinstall from https://git-scm.com/"

  # Check user
  pass[["git_user"]] <- gert::user_is_configured()
  if (!pass[["git_user"]])
    errors[["git_user"]] <-
    "No user configured; please run worcs::git_user(yourname, youremail, overwrite = TRUE)"

  # Check libgit for SSH
  libgit <- gert::libgit2_config()
  pass[["libgit2"]] <- !is.null(libgit[["version"]])
  if (pass[["libgit2"]]) {
    pass[["libgit2"]] <- libgit$ssh
  }
  if (!pass[["libgit2"]]) {
    errors[["libgit2"]] <-
      "libgit2 is not properly installed and you may not be able to use the SSH protocol to connect to Git remote repositories."
  }

  # Check that one can create a repo
  the_test <- "git"
  dir_name <- file.path(tempdir(), the_test)
  if (dir.exists(dir_name))
    unlink(dir_name, recursive = TRUE, force = TRUE)
  dir.create(dir_name)
  pass[["git_init"]] <-
    !inherits(try({
      gert::git_init(dir_name)
    }, silent = TRUE)
    , "try-error")
  if (!pass[["git_init"]]) {
    errors[["git_init"]] <-
      "Package gert could not initialize a Git repository."
  } else {
    # More tests
    writeLines("test git", con = file.path(dir_name, "tmp.txt"))
    tmp <- gert::git_add(".", repo = dir_name)
    pass[["git_add"]] <- isTRUE(tmp$staged)
    if (!pass[["git_add"]]) {
      errors[["git_add"]] <-
        "Package gert could not add files to Git repository."
    } else {
      # More tests
      pass[["git_commit"]] <-
        !inherits(try(gert::git_commit("First commit", repo = dir_name),
                      silent = TRUE)
                  , "try-error")
      if (!pass[["git_commit"]]) {
        errors[["git_commit"]] <-
          "Package gert could not commit to Git repository."
      }
    }
  }
  if(isTRUE(all(unlist(pass)))){
    pass <- list(git = TRUE)
    errors <- list()
  }
  unlink(dir_name, recursive = TRUE, force = TRUE)
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @param pat Logical, whether to run tests for the existence and functioning of
#' a GitHub Personal Access Token (PAT). This is the preferred method of
#' authentication, so defaults to TRUE.
#' @param ssh Logical, whether to run tests for the existence and functioning of
#' an SSH key. This method of authentication is not recommended, so defaults to
#' FALSE.
#' @export
check_github <- function(pat = TRUE, ssh = FALSE) {
  pass <- list()
  errors <- list()
  # Check if currently in a git repo with remote
  repo <- try({gert::git_remote_list()})
  if(!inherits(repo, "try-error")){
    if(isTRUE(grepl("^https://", repo$url))) pass[["current git repo has a remote that requires PAT authentication"]] <- TRUE
    if(isTRUE(grepl("^git@", repo$url))) pass[["current git repo has a remote that requires SSH authentication"]] <- TRUE
  }
  if(pat){
    pass[["github_pat"]] <- isFALSE(gh::gh_token() == "")
    if (!pass[["github_pat"]])
      errors[["github_pat"]] <-
        "You have not set a Personal Access Token (PAT) for GitHub; to fix this, run usethis::create_github_token(), create a PAT and copy it, then run gitcreds::gitcreds_set() and paste the PAT when asked. If you still experience problems try usethis::gh_token_help() for help."

    # github pat grants access
    if(pass[["github_pat"]]){
      result <- tryCatch(gh::gh("/user"), error = function(e)e)
      pass[["github_pat_response"]] <- isTRUE(inherits(result, "gh_response"))
      if (!pass[["github_pat_response"]]){
        errors[["github_pat_response"]] <- "The Personal Access Token (PAT) in your Git credential store does not grant access to GitHub. To fix this, run usethis::create_github_token(), create a PAT and copy it, then run gitcreds::gitcreds_set() and paste the PAT when asked. If you still experience problems try usethis::gh_token_help() for help."
        if(inherits(result, "http_error_401")){
          errors[["github_pat_response"]] <- "The Personal Access Token (PAT) in your Git credential store does not grant access to GitHub. It may have expired. To fix this, run usethis::create_github_token(), create a PAT and copy it, then run gitcreds::gitcreds_set() and paste the PAT when asked. If you still experience problems try usethis::gh_token_help() for help."
        }
        if(inherits(result, "rlib_error") && grepl("one of these forms", result$message)){
          errors[["github_pat_response"]] <- "The Personal Access Token (PAT) in your Git credential store has the wrong format. To fix this, run usethis::create_github_token(), create a PAT and copy it, then run gitcreds::gitcreds_set() and paste the PAT when asked. If you still experience problems try usethis::gh_token_help() for help."
        }
      }
    }
  }
  if(ssh){
    # Check SSH
    sshres <- check_ssh()
    pass <- c(pass, sshres$pass)
    errors <- c(errors, sshres$errors)
    # GitHub SSH
    temp <- tempfile()
    system2("ssh",
            "-T git@github.com",
            stdout = temp,
            stderr = temp)
    output <- readLines(temp)
    pass[["github_ssh"]] <-
      isTRUE(any(grepl("success", output, fixed = TRUE)))
    # Maybe check if *any* type of authentication is possible
    if (!pass[["github_ssh"]])
      errors[["github_ssh"]] <-
      "Could not authenticate GitHub via SSH, but that's OK. We recommend using a Personal Access Token (PAT). If you intend to use SSH with GitHub, consult https://happygitwithr.com/rstudio-git-github.html"
  }

  if(isTRUE(all(unlist(pass)))){
    pass <- list(github = TRUE)
    errors <- list()
  }
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @export
check_ssh <- function() {
  pass <- list()
  errors <- list()
  pass[["ssh"]] <-
    isTRUE(!inherits(try(credentials::ssh_key_info(host = NULL, auto_keygen = FALSE)$key,
                         silent = TRUE)
                     , "try-error") &
             !inherits(try(credentials::ssh_read_key(), silent = TRUE)
                       , "try-error"))

  if (!pass[["ssh"]])
    errors[["ssh"]] <-
    "Could not find a valid SSH key, but that's OK. We recommend using a Personal Access Token (PAT). If you do wish to set up SSH, please consult https://happygitwithr.com/ssh-keys.html"
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @export
check_tinytext <- function() {
  pass <- list()
  errors <- list()
  pass[["tinytex"]] <- !inherits(try({
    tmpfl <- tempfile(fileext = ".tex")
    writeLines(
      c(
        '\\documentclass{article}',
        '\\begin{document}',
        'Hello world!',
        '\\end{document}'
      ),
      tmpfl
    )
    tmp <- tinytex::pdflatex(tmpfl)
    isTRUE(endsWith(tmp, ".pdf"))
  }, silent = TRUE)
  , "try-error")

  if (!pass[["tinytex"]])
    errors[["tinytex"]] <-
    "tinytex could not render a pdf document and may need to be reinstalled; please turn to https://yihui.org/tinytex/"
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @export
check_rmarkdown <- function() {
  pass <- list()
  errors <- list()
  pass[["rmarkdown_html"]] <- !inherits(try({
    tmpinp <- tempfile(fileext = ".rmd")
    tmpout <- tempfile(fileext = ".html")
    writeLines(
      c(
        '---',
        'title: "Untitled"',
        'author: "test"',
        'output: html_document',
        '---'
      ),
      tmpinp
    )
    tmp <-
      rmarkdown::render(input = tmpinp,
                        output_file = tmpout,
                        quiet = TRUE)
    isTRUE(endsWith(tmp, ".html"))
  }, silent = TRUE)
  , "try-error")

  if (!pass[["rmarkdown_html"]])
    errors[["rmarkdown_html"]] <-
    "Rmarkdown could not render a HTML file."

  pass[["rmarkdown_pdf"]] <- !inherits(try({
    tmpinp <- tempfile(fileext = ".rmd")
    tmpout <- tempfile(fileext = ".pdf")
    writeLines(
      c(
        '---',
        'title: "Untitled"',
        'author: "test"',
        'output: pdf_document',
        '---'
      ),
      tmpinp
    )
    tmp <-
      rmarkdown::render(input = tmpinp,
                        output_file = tmpout,
                        quiet = TRUE)
    isTRUE(endsWith(tmp, ".pdf"))
  }, silent = TRUE)
  , "try-error")

  if (!pass[["rmarkdown_pdf"]])
    errors[["rmarkdown_pdf"]] <-
    "Rmarkdown could not render a PDF file."
  if(isTRUE(all(unlist(pass)))){
    pass <- list(rmarkdown = TRUE)
    errors <- list()
  }
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}


#' @rdname check_worcs_installation
#' @export
check_renv <- function() {
  pass <- list()
  errors <- list()
  pass[["renv_consent"]] <- !inherits(try({
    {
      sink(tempfile())
      tmp <- invisible(renv::consent())
      sink()

    }
    if (!isTRUE(tmp))
      stop()
  }, silent = TRUE)
  , "try-error")

  if (!pass[["renv_consent"]])
    errors[["renv_consent"]] <-
    "renv does not have consent yet; run renv::consent(provided = TRUE)"
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

# Show results ------------------------------------------------------------
#' @method print worcs_check
#' @export
print.worcs_check <- function(x, ...){
  pass <- unlist(x$pass)
  for (n in names(pass)) {
    if (pass[n]) {
      col_message(n, success = TRUE)
    } else {
      col_message(paste0(n, ": ", x$errors[[n]]), success = FALSE)
    }
  }
}

get_deps <- function(package = "worcs") {
  pks <- packageDescription(package)
  if (isTRUE(is.na(pks)))
    return(vector("character"))
  pks <- gsub("\n", "", pks$Imports, fixed = TRUE)
  pks <- gsub("\\s", "", pks)
  pks <- strsplit(pks, ",")[[1]]
  setdiff(
    pks,
    c(
      "R",
      "stats",
      "graphics",
      "grDevices",
      "utils",
      "datasets",
      "methods",
      "base",
      "tools"
    )
  )
}
