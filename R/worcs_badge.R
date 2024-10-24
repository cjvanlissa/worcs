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
  ndir <- np <- normalizePath(path)
  if(endsWith(path, "checklist.csv")){
    ndir <- dirname(np)
    checks <- read.csv(path, stringsAsFactors = FALSE)
    checks$check <- as.logical(checks$check)
    checks$pass <- as.logical(checks$pass)
    if(anyNA(checks$pass)) stop("All values in the 'pass' column must be either TRUE or FALSE. Check your .csv file for spelling errors.", call. = FALSE)
    if(anyNA(checks$check)) stop("All values in the 'check' column must be either TRUE or FALSE. Check your .csv file for spelling errors.", call. = FALSE)
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
    if(!is_abs(update_readme)){ # is relative
      update_readme <- file.path(ndir, update_readme)
    }

    switch(level,
           perfect = use_badge("WORCS", "https:doi.org/10.3233/DS-210031", src = "https://img.shields.io/badge/WORCS-perfect-blue"),
           limited = use_badge("WORCS", "https:doi.org/10.3233/DS-210031", src = "https://img.shields.io/badge/WORCS-limited-orange"),
           open = use_badge("WORCS", "https:doi.org/10.3233/DS-210031", src = "https://img.shields.io/badge/WORCS-open%20science-brightgreen"),
           use_badge("WORCS", "https:doi.org/10.3233/DS-210031", src = "https://img.shields.io/badge/WORCS-fail-red")
    )
  }
  if(!is.null(update_csv)){
    if(!is_abs(update_csv)){ # is relative
      update_csv <- file.path(ndir, update_csv)
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
    worcsfile <- read_yaml(file.path(path, ".worcs"))
    checks <- worcs_checklist
    checks[sapply(checks, inherits, what = "factor")] <- lapply(checks[sapply(checks, inherits, what = "factor")], as.character)
    checks$pass <- FALSE

    # Get files in folder. This is potentially inefficient, as the entire renv directory is also indexed.
    f <- list.files(path, recursive = TRUE, full.names = TRUE)
    f_lc <- tolower(f)

    # See what files are tracked by git
    tracked <- tryCatch({
      git_ls(repo = path)
    }, error = function(e){NULL})
    # If git tracks any files
    checks$pass[checks$name == "git_repo"] <- length(tracked) > 0
    # If git has a remote
    checks$pass[checks$name == "has_remote"] <- tryCatch({dim(git_remote_list(path))[1] > 0}, error = function(e){FALSE})

    # Do checks
    checks$pass[checks$name == "readme"] <- any(endsWith(f_lc, "readme.md"))
    checks$pass[checks$name == "license"] <- any(endsWith(f_lc, "license")|endsWith(f_lc, "license.md"))
    checks$pass[checks$name == "citation"] <- {
      rmarkdown_files <- f[endsWith(tolower(f_lc), ".rmd")]
      any(sapply(rmarkdown_files, function(thisfile){
        txt <- paste0(readLines(thisfile, encoding = "UTF-8"), collapse = "")
        grepl("@", txt, fixed = TRUE) & grepl("\\.bib", txt)
      }))
    }
    checks$pass[checks$name == "data"] <- tryCatch({
      if(!is.null(worcsfile[["data"]]) & length(tracked) > 0){
        worcs_data <- names(worcsfile$data)
        worcs_data <- c(worcs_data, unlist(sapply(worcsfile$data[sapply(worcsfile$data, function(x){!is.null(x[["synthetic"]])})], `[[`, "synthetic")))
        any(tolower(worcs_data) %in% tolower(tracked$path))
      }
    }, error = function(e){FALSE})

    # If checksums are up to date
    if(checks$pass[checks$name == "data"]){
      checks$pass[checks$name == "data_checksums"] <-
        tryCatch({
          #cs_now <- sapply(worcs_data, digest, file = TRUE)
          cs_now <- sapply(worcs_data, cs_fun, worcsfile = file.path(path, ".worcs"))
          names(cs_now) <- worcs_data
          cs_stored <- unlist(worcsfile$checksums)
          if(all(names(cs_now) %in% names(cs_stored))){
            all(sapply(names(cs_now), function(x){cs_now[x] == cs_stored[x]}))
          } else {
            FALSE
          }
        }, error = function(e){FALSE})
    } else {
      checks$pass[checks$name == "data_checksums"] <- FALSE
    }

    # If project has R-code
    checks$pass[checks$name == "code"] <- any(endsWith(f_lc, ".r"))
    # If project has preregistration
    checks$pass[checks$name == "preregistration"] <- any(endsWith(tolower(f_lc), "preregistration.rmd"))
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
