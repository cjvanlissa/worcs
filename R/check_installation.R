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
  checkfuns <- c("check_dependencies", "check_git", "check_github", "check_renv", "check_rmarkdown", "check_ssh", "check_tinytext")

  # checkfuns <- ls(asNamespace("worcs"))
  # checkfuns <- checkfuns[startsWith(checkfuns, "check_")]
  # checkfuns <- setdiff(checkfuns, c("check_recursive", "check_sum", "check_worcs", "check_worcs_installation"))
  if(!what == "all"){
    checkfuns <- checkfuns[checkfuns %in% paste0("check_", what)]
    if(isFALSE(length(checkfuns) > 0)){
      stop("Argument 'what' does not refer to any valid checks.")
    }
  }
  out <- lapply(checkfuns, do.call, args = list())
  worcs_checkres <- list(pass = do.call(c, lapply(out, `[[`, "pass")),
                         errors = do.call(c, lapply(out, `[[`, "errors")))
  class(worcs_checkres) <- c("worcs_check", class(worcs_checkres))
  print(worcs_checkres)
  return(invisible(isTRUE(all(pass))))
}

#' @rdname check_worcs_installation
#' @param package Atomic character vector, indicating for which package to check
#' the dependencies.
#' @export
check_dependencies <- function(package = "worcs") {
  thesedeps <- get_deps(package = package)
  available <- installed.packages()[, "Package"]
  if (all(thesedeps %in% available)) {
    out <- list(pass = list(dependencies = TRUE), errors = list(dependencies = ""))
  } else {
    errors <- thesedeps[!thesedeps %in% available]
    out <- list(
      pass = list(dependencies = FALSE),
      errors = list(
        dependencies = paste0(
          "The following packages are not installed, run install.packages() for: ",
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
  unlink(dir_name, recursive = TRUE, force = TRUE)
  out <- list(pass = pass, errors = errors)
  class(out) <- c("worcs_check", class(out))
  return(out)
}

#' @rdname check_worcs_installation
#' @export
check_github <- function() {
  pass <- list()
  errors <- list()
  pass[["github_pat"]] <- isFALSE(gh::gh_token() == "")
  if (!pass[["github_pat"]])
    errors[["github_pat"]] <-
    "You do not have a personal access token for GitHub; if you intend to use GitHub, consider creating one following the instructions at https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token. Then, run credentials::set_github_pat('YourPAT') in R."

  # GitHub SSH
  temp <- tempfile()
  system2("ssh",
          "-T git@github.com",
          stdout = temp,
          stderr = temp)
  output <- readLines(temp)
  pass[["github_ssh"]] <-
    isTRUE(any(grepl("success", output, fixed = TRUE)))
  if (!pass[["github_ssh"]])
    errors[["github_ssh"]] <-
    "Could not authenticate GitHub via SSH; if you intend to use GitHub, consult https://happygitwithr.com/rstudio-git-github.html"
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
    "Could not find a valid SSH key; please consult https://happygitwithr.com/ssh-keys.html"
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
