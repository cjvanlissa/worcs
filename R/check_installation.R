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
  checkfuns <- c("check_dependencies", "check_git", "check_github", "check_renv", "check_rmarkdown", "check_tinytex")

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
    eval(str2lang(paste0("worcs::", thisfun, "()")))
    })

  return(invisible(isTRUE(all(unlist(out)))))
}

#' @rdname check_worcs_installation
#' @param package Atomic character vector, indicating for which package to check
#' the dependencies.
#' @export
check_dependencies <- function (package = "worcs")
{
  with_cli_try("Checking R package dependencies.", {
    available <- data.frame(installed.packages())
    thesedeps <- unique(unlist(lapply(package, function(this_package){

      pks <- packageDescription(this_package)
      if (isTRUE(is.na(pks))){
        return(vector("character"))
      } else {
        pks <- pks[c("Depends", "Imports", "Suggests")]
        pks <- lapply(pks, function(p){
          p <- gsub("\n", "", p, fixed = TRUE)
          p <- gsub("\\s", "", p)
          strsplit(p, ",")[[1]]
        })
        return(do.call(c, pks))
      }
    })))
    if(any(grepl("^R\\b", thesedeps))) thesedeps <- thesedeps[!grepl("^R\\b", thesedeps)]
    # setdiff(pks, c("R", "stats", "graphics", "grDevices",
    #                "utils", "datasets", "methods", "base", "tools"))
    has_version <- grepl("(", thesedeps, fixed = TRUE)
    correct_vers <- rep(TRUE, length(thesedeps))
    if (any(has_version)) {
      vers <- data.frame(do.call(rbind, strsplit(thesedeps[has_version],
                                                 "(", fixed = TRUE)))
      vers[, 2] <- gsub(")", "", vers[, 2], fixed = TRUE)
      vers$op <- gsub("[0-9\\.]", "", vers[, 2])
      vers[, 2] <- gsub("[^0-9.-]", "", vers[, 2])
      thesedeps[has_version] <- vers[, 1]
      correct_vers[has_version] <- sapply(seq_along(vers$X1), function(i) {
        tryCatch({
          n = vers$X1[i]
          if(n == "R") return(TRUE)
          do.call(vers$op[i], list(x = packageVersion(n),
                                   y = vers[i, 2]))
        }, error = function(e) {
          FALSE
        })
      })
    }
    is_avlb <- thesedeps %in% available$Package
    if (all(is_avlb & correct_vers)) {
      out <- list(pass = list(dependencies = TRUE), errors = list(dependencies = ""))
    }
    else {
      errors <- thesedeps[which(!(is_avlb & correct_vers))]
      errors <- paste0("lapply(c(", paste0("'", errors,
                                           "'", collapse = ", "), "), install.packages)")
      cli_msg(i = "The following packages are not installed (or their correct versions are not installed), run {.code {errors}}.")
      stop()
    }
  })
}

#' @rdname check_worcs_installation
#' @export
check_git <- function() {
  pass <- list()
  errors <- list()
  # Check command line git
  pass[["git_cmd"]] <- with_cli_try("Check if Git is available on the command line.", {
    system2("git",
            "--version",
            stdout = tempfile(),
            stderr = tempfile()) == 0L
  })
  if (!pass[["git_cmd"]]) cli_msg("i" = "Please reinstall Git from {.url https://git-scm.com/}.")


  # Check libgit for SSH

  pass[["libgit2"]] <- with_cli_try("Checking if libgit2 is properly installed, required for connecting to Git remote repositories from R.", {
    libgit <- gert::libgit2_config()
    if(is.null(libgit[["version"]]) | !libgit$ssh) stop()
  })

  if (!pass[["libgit2"]]) {
    cli_msg("i" = "libgit2 is not properly installed and you may not be able to use the SSH protocol to connect to Git remote repositories.")
  }

  # Check that one can create a repo
  the_test <- "git"
  dir_name <- file.path(tempdir(), the_test)
  if (dir.exists(dir_name))
    unlink(dir_name, recursive = TRUE, force = TRUE)
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE, force = TRUE))
  pass[["git_init"]] <- with_cli_try("Initiating Git repository.", {
    gert::git_init(dir_name)
  })

  # Check user
  pass[["git_user"]] <- with_cli_try("Git user is configured.", { gert::user_is_configured() })
  if (!pass[["git_user"]])
    cli_msg("i" = "No user configured; please run {.code worcs::git_user({.val your_name}, {.val your_email}, overwrite = TRUE)}.")

  if (pass[["git_init"]]) {
    # More tests
    writeLines("test git", con = file.path(dir_name, "tmp.txt"))

    pass[["git_add"]] <- with_cli_try("Adding files with {.code gert::git_add()}.", {
      tmp <- gert::git_add(".", repo = dir_name)
      isTRUE(tmp$staged)
      })
    if (pass[["git_add"]]) {
      # More tests
      pass[["git_commit"]] <- with_cli_try("Committing with {.code gert::git_commit()}.", {
        gert::git_commit("First commit", repo = dir_name, author = gert::git_signature("test", "test@test.com"))
      })
    }
  }
  return_status <- tryCatch(all(unlist(pass)), error = function(e){FALSE})
  return(invisible(return_status))

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

  # Check if currently in a git repo with remote
  repo <- try({gert::git_remote_list()}, silent = TRUE)
  if(!inherits(repo, "try-error")){
    if(isTRUE(grepl("^https://", repo$url))) cli_msg("i" = "Active project has a remote repository that requires PAT authentication.")
    if(isTRUE(grepl("^git@", repo$url))) cli_msg("i" = "Active project has a remote that requires SSH authentication.")
  }
  if(pat){
    pass[["github_pat"]] <- with_cli_try("Check for PAT.", {
      if(gh::gh_token() == "") stop()
      # github pat grants access
      result <- tryCatch(gh::gh("/user"), error = function(e)e)
      if(inherits(result, "http_error_401")){
        cli_msg("i" = "The Personal Access Token (PAT) may have expired.")
      }
      if(inherits(result, "rlib_error") && grepl("one of these forms", result$message)){
        cli_msg("i" = "The Personal Access Token (PAT) has the wrong format.")
      }
      if(!isTRUE(inherits(result, "gh_response"))) stop()
    })
    if (!pass[["github_pat"]]) cli_msg("i" = "You have not set a Personal Access Token (PAT) for GitHub; to fix this, run {.code usethis::create_github_token()}, create a PAT and copy it, then run {.code gitcreds::gitcreds_set()} and paste the PAT when asked. If you still experience problems try {.code usethis::gh_token_help()} for help.")



  }
  if(ssh){
    # Check SSH


    # GitHub SSH
    pass[["github_ssh"]] <- with_cli_try("Connecting to GitHub using SSH", {
      if(!check_ssh()) stop()
      temp <- tempfile()
      system2("ssh",
              "-T git@github.com",
              stdout = temp,
              stderr = temp)
      output <- readLines(temp)
      if(!isTRUE(any(grepl("success", output, fixed = TRUE)))){
        cli_msg("i" = "Could not authenticate GitHub via SSH, but that's OK. We recommend using a Personal Access Token (PAT). If you intend to use SSH with GitHub, consult https://happygitwithr.com/rstudio-git-github.html")
        stop()
      }
    })

  }

  return(invisible(isTRUE(all(unlist(pass)))))
}

#' @rdname check_worcs_installation
#' @export
check_ssh <- function() {
  with_cli_try("Checking for valid SSH key.", {
    if(!isTRUE(!inherits(try(credentials::ssh_key_info(host = NULL, auto_keygen = FALSE)$key,
                         silent = TRUE)
                     , "try-error") &
             !inherits(try(credentials::ssh_read_key(), silent = TRUE)
                       , "try-error"))){
      cli_msg("i" = "Could not find a valid SSH key, but that's OK. We recommend using a Personal Access Token (PAT). If you do wish to set up SSH, please consult https://happygitwithr.com/ssh-keys.html")
      stop()
    }
    })
}

#' @rdname check_worcs_installation
#' @keywords internal
#' @export
check_tinytext <- function(){
  .Deprecated("check_tinytex")
}

#' @rdname check_worcs_installation
#' @export
check_tinytex <- function() {
  with_cli_try("Rendering document to PDF with tinytex.", {
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
    if(!isTRUE(endsWith(tmp, ".pdf"))){
      cli_msg("i" = "tinytex may need to be reinstalled; please turn to {.url https://yihui.org/tinytex/}")
      stop()
    }
  })
}

#' @rdname check_worcs_installation
#' @export
check_rmarkdown <- function() {

  pass <- with_cli_try("Checking that rmarkdown can render a HTML file.", {
    tmpinp <- tempfile(fileext = ".Rmd")
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
    if(!isTRUE(endsWith(tmp, ".html"))){
      stop()
    }
  })
  pass <- c(pass, with_cli_try("Checking that rmarkdown can render a PDF file.", {
    tmpinp <- tempfile(fileext = ".Rmd")
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
    if(!isTRUE(endsWith(tmp, ".pdf"))) stop()
  }))

  return(invisible(isTRUE(all(pass))))
}


#' @rdname check_worcs_installation
#' @export
check_renv <- function() {
  with_cli_try("Checking that renv works.", {
    sink(tempfile())
    tmp <- invisible(renv::consent())
    sink()
    if (!isTRUE(tmp)){
      cli_msg("i" = "renv does not have consent yet; run {.code renv::consent(provided = TRUE)}")
      stop()
    }
  })
}

# Show results ------------------------------------------------------------
# @method print worcs_check
# @export
# print.worcs_check <- function(x, ...){
#   pass <- unlist(x$pass)
#   for (n in names(pass)) {
#     if (pass[n]) {
#       col_message(n, success = TRUE)
#     } else {
#       col_message(paste0(n, ": ", x$errors[[n]]), success = FALSE)
#     }
#   }
# }

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
