if(getRversion() >= "2.15.1") utils::globalVariables(c("worcs_checklist"))

#' @title Add WORCS badge to README.md
#' @description Evaluates whether a project meets the criteria of the WORCS
#' checklist (see \code{\link{worcs_checklist}}), and adds a badge to the
#' project's \code{README.md}.
#' @param path Character. This can either be the path to a WORCS project folder
#' (a project with a \code{.worcs} file), or the path to a \code{checklist.csv}
#' file. The latter is useful if you want to evaluate a manually updated
#' checklist file. Default: '.' (path to current directory).
#' @param update_readme Character. Path to the \code{README.md} file to add the
#' badge to. Default: 'README.md'. Set to \code{NULL} to avoid updating the
#' \code{README.md} file.
#' @param update_csv Character. Path to the \code{README.md} file to add the
#' badge to. Default: 'checklist.csv'. Set to \code{NULL} to avoid updating the
#' \code{checklist.csv} file.
#' @return No return value. This function is called for its side effects.
#' @examples
#' example_dir <- file.path(tempdir(), "badge")
#' dir.create(example_dir)
#' write("a", file.path(example_dir, ".worcs"))
#' worcs_badge(path = example_dir,
#' update_readme = NULL)
#' @rdname worcs_badge
#' @export
worcs_badge <- function(path = ".",
                        update_readme = "README.md",
                        update_csv = "checklist.csv"){
  np <- normalizePath(path)
  if(endsWith("checklist.csv", path)){
    checks <- read.csv(path, stringsAsFactors = FALSE)
  } else {
    checks <- do.call(check_worcs, list(path = np))
  }
  level <- "fail"
  if(all(checks$pass)){
    level <- "perfect"
  } else {
    if(any(checks$pass[checks$importance == "essential"])){
      level <- c("limited", "open")[all(checks$pass[checks$importance == "essential"])+1]
    }
  }
  if(!is.null(update_readme)){
    tryCatch({
      if(!is_abs(update_readme)){ # is relative
        update_readme <- file.path(np, update_readme)
      }
      text <- readLines(update_readme)
      loc <- startsWith(text, "[![WORCS](https://img.shields.io/badge/WORC")
      if(any(loc)){
        loc <- which(loc)[1]
        text <- text[-loc]
        loc <- loc-1
      } else {
        loc <- which(startsWith(text, "#"))[1]+1
      }
      text <- append(x = text,
             values = switch(level,
                             perfect = c("", "[![WORCS](https://img.shields.io/badge/WORCS-perfect-blue)](https://osf.io/zcvbs/)", ""),
                             limited = c("", "[![WORCS](https://img.shields.io/badge/WORCS-limited-orange)](https://osf.io/zcvbs/)", ""),
                             open = c("", "[![WORCS](https://img.shields.io/badge/WORCS-open%20science-brightgreen)](https://osf.io/zcvbs/)", ""),
                             c("", "[![WORCS](https://img.shields.io/badge/WORCS-fail-red)](https://osf.io/zcvbs/)", "")),
             after = loc
      )
      writeLines(text, update_readme)
    }, error = function(e){warning("Could not update README.md")})
  }
  if(!is.null(update_csv)){
    if(!is_abs(update_csv)){ # is relative
      update_csv <- file.path(np, update_csv)
    }
    write.csv(checks, update_csv, row.names = FALSE)
    write_gitig(file.path(dirname(update_csv), ".gitignore"), paste0("!", basename(update_csv)))
  }
}

#' @title Evaluate project with respect to WORCS checklist
#' @description Evaluates whether a project meets the criteria of the WORCS
#' checklist (see \code{\link{worcs_checklist}}).
#' @param path Character. Path to a WORCS project folder (a project with a
#' \code{.worcs} file). Default: '.' (path to current directory).
#' @param verbose Logical. Whether or not to show status messages while
#' evaluating the checklist. Default: \code{TRUE}.
#' @return A \code{data.frame} with a description of the criteria, and a column
#' with evaluations (\code{$pass}). For criteria that must be evaluated
#' manually, \code{$pass} will be \code{FALSE}.
#' @examples
#' example_dir <- file.path(tempdir(), "badge")
#' dir.create(example_dir)
#' write("a", file.path(example_dir, ".worcs"))
#' check_worcs(path = example_dir)
#' @rdname check_worcs
#' @export
#' @importFrom gert git_remote_list
#' @importFrom utils data
check_worcs <- function(path = ".", verbose = TRUE){
  if(!file.exists(file.path(path, ".worcs"))){
    stop("No WORCS project found in directory '", path, "'")
  } else {
    checks <- worcs_checklist
    checks[sapply(checks, inherits, what = "factor")] <- lapply(checks[sapply(checks, inherits, what = "factor")], as.character)
    checks$pass <- FALSE

    # Get files in folder
    f <- list.files(path, recursive = TRUE, full.names = TRUE)
    f_lc <- tolower(f)

    # See what files are tracked by git
    tracked <- tryCatch({
      git_ls(path)
    }, error = function(e){NULL})

    # Do checks
    checks$pass[checks$name == "readme"] <- any(endsWith(f_lc, "readme.md"))
    checks$pass[checks$name == "license"] <- any(endsWith(f_lc, "license")|endsWith(f_lc, "license.md"))
    checks$pass[checks$name == "citation"] <- {
      rmarkdown_files <- f[endsWith(f_lc, ".rmd")]
      any(sapply(rmarkdown_files, function(thisfile){
        txt <- paste0(readLines(thisfile), collapse = "")
        grepl("@", txt, fixed = TRUE) & grepl("\\.bib", txt)
      }))
    }
    checks$pass[checks$name == "data"] <- tryCatch({
      if(length(tracked) > 0){
        any(endsWith(tolower(tracked$path), "data.csv"))
      } else {
        FALSE
      }
    }, error = function(e){FALSE})
    tracked_data <- if(length(tracked) > 0){
      tryCatch({
        tracked$path[grepl("\\bdata.csv$", tolower(tracked$path), fixed = TRUE)|grepl("\\bsynthetic_data.csv$", tolower(tracked$path), fixed = TRUE)]
      }, error = function(e){NULL})
    } else {
      NULL
    }
    # If git tracks any files
    if(length(tracked) > 0){
      checks$pass[checks$name == "git_repo"] <- TRUE
      checks$pass[checks$name == "has_remote"] <- dim(git_remote_list(path))[1] > 0
      # If some of those files are data
      if(length(tracked_data) > 0){
        checks$pass[checks$name == "data"] <- TRUE
        checks$pass[checks$name == "data_checksums"] <-
          tryCatch({
            cs_now <- sapply(tracked_data, digest, file = TRUE)
            cs_stored <- unlist(read_yaml(".worcs")$checksums)
            if(all(names(cs_now) %in% names(cs_stored))){
              all(sapply(names(cs_now), function(x){cs_now[x] == cs_stored[x]}))
            } else {
              FALSE
            }
          }, error = function(e){FALSE})
      } else {
        checks$pass[checks$name %in% c("data", "data_checksums")] <- FALSE
      }
    } else {
      checks$pass[checks$name %in% c("git_repo", "has_remote", "data", "data_checksums")] <- FALSE
    }
    checks$pass[checks$name == "code"] <- any(endsWith(f_lc, ".r"))
    checks$pass[checks$name == "preregistration"] <- any(endsWith(f_lc, "preregistration.rmd"))
  }
  if(verbose){
    tmp <- apply(checks[worcs_checklist$check, ], 1, function(thisrow){
      col_message(thisrow["description"], success = thisrow["pass"])
    })
  }
  return(checks)
}


is_abs <- function(filename){
  grepl("^(/|[A-Za-z]:|\\\\|~)", filename)
}
