#' @title Check worcs dependencies
#' @description This function checks that all worcs dependencies are correctly
#' installed, and suggests how to remedy any missing dependencies.
#' @param what Character vector indicating which dependencies to check. Default:
#' `"all"`. Options include: `c("dependencies", "git_user", "libgit2",
#' "git_init", "git_add", "git_commit", "SSH", "tinytex")`.
#' @return Logical, indicating whether all checks passed or not.
#' @examples
#' check_worcs_installation("dependencies")
#' @rdname check_worcs_installation
#' @export
#' @importFrom gert user_is_configured libgit2_config git_init git_add git_commit
#' @importFrom credentials ssh_key_info
#' @importFrom tinytex pdflatex
#' @importFrom utils packageDescription
check_worcs_installation <- function(what = "all"){
  pass <- list()
  errors <- list()
  if(any(c("all", "dependencies") %in% what)){
    thesedeps <- get_deps()
    available <- installed.packages()[, "Package"]
    if(all(thesedeps %in% available)){
      pass[["dependencies"]] <- TRUE
    } else {
      errors[["dependencies"]] <- thesedeps[!thesedeps %in% available]
      errors[["dependencies"]] <- paste0("The following packages are not installed, run install.packages() for: ", paste0(errors[["dependencies"]], collapse = ", "))
      pass[["dependencies"]] <- FALSE
    }
  }


  # Git ---------------------------------------------------------------------

  if(any(c("all", "git") %in% what)){
    # Check user
    pass[["git_user"]] <- gert::user_is_configured()
    if(!pass[["git_user"]]) errors[["git_user"]] <- "No user configured; please run worcs::git_user(yourname, youremail, overwrite = TRUE)"

    # Check libgit for SSH
    libgit <- gert::libgit2_config()
    pass[["libgit2"]] <- !is.null(libgit[["version"]])
    if(pass[["libgit2"]]){
      pass[["libgit2"]] <- libgit$ssh
    }
    if(!pass[["libgit2"]]){
      errors[["libgit2"]] <- "libgit2 is not properly installed and you may not be able to use the SSH protocol to connect to Git remote repositories."
    }

    # Check that one can create a repo
    the_test <- "git"
    dir_name <- file.path(tempdir(), the_test)
    if(dir.exists(dir_name)) unlink(dir_name, recursive = TRUE, force = TRUE)
    dir.create(dir_name)
    pass[["git_init"]] <- tryCatch({
      gert::git_init(dir_name);
      TRUE}, error = function(e){ FALSE })
    if(!pass[["git_init"]]){
      errors[["git_init"]] <- "Package gert could not initialize a Git repository."
    } else {
      # More tests
      writeLines("test git", con = file.path(dir_name, "tmp.txt"))
      tmp <- gert::git_add(".", repo = dir_name)
      pass[["git_add"]] <- isTRUE(tmp$staged)
      if(!pass[["git_add"]]){
        errors[["git_add"]] <- "Package gert could not add files to Git repository."
      } else {
        # More tests
        pass[["git_commit"]] <- tryCatch({
          gert::git_commit("First commit", repo = dir_name);
          TRUE}, error = function(e){ FALSE })
        if(!pass[["git_commit"]]){
          errors[["git_commit"]] <- "Package gert could not commit to Git repository."
        }
      }
    }
    unlink(dir_name, recursive = TRUE, force = TRUE)
  }


  # SSH ---------------------------------------------------------------------
  if(any(c("all", "SSH") %in% what)){
    pass[["SSH"]] <- tryCatch({
      tmp <- credentials::ssh_key_info()
      isTRUE(!is.null(tmp$key)) & isTRUE(!is.null(tmp$pubkey))
    }, error = function(e){
      FALSE
    })
    if(!pass[["SSH"]]) errors[["SSH"]] <- "Could not find a valid SSH key; please turn to https://happygitwithr.com/ssh-keys.html"
  }

  # tinytex -----------------------------------------------------------------
  if(any(c("all", "tinytex") %in% what)){
    pass[["tinytex"]] <- tryCatch({
      tmpfl <- tempfile(fileext = ".tex")
      writeLines(c(
        '\\documentclass{article}',
        '\\begin{document}', 'Hello world!', '\\end{document}'
      ), tmpfl)
      tmp <- tinytex::pdflatex(tmpfl)
      isTRUE(endsWith(tmp, ".pdf"))
    }, error = function(e){
      FALSE
    })
    if(!pass[["tinytex"]]) errors[["tinytex"]] <- "tinytex could not render a pdf document and may need to be reinstalled; please turn to https://yihui.org/tinytex/"
  }
  pass <- unlist(pass)
  padlength <- max(sapply(names(pass), nchar))
  for(n in names(pass)){
    if(pass[n]){
      col_message(n, success = TRUE)
    } else {
      col_message(paste0(sprintf(paste0("%-", padlength, "s"), n), ": ", errors[[n]]), success = FALSE)
    }
  }
  return(invisible(all(pass)))
}

get_deps <- function() {
  pks <- packageDescription("worcs")$Imports
  pks <- gsub("\n", "", pks, fixed = TRUE)
  pks <- gsub("\\s", "", pks)
  pks <- strsplit(pks, ",")[[1]]
  setdiff(pks, c(
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
