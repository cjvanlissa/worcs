#' @importFrom rmarkdown draft
#' @importFrom gert git_init git_remote_add git_add git_commit git_push
# @importFrom renv init
worcs_template <- function(path, ...) {
  # collect inputs
  dots <- list(...)
  prereg_template <- dots[["prereg_template"]]
  use_renv <- dots[["use_renv"]]
  remote_repo <- dots[["remote_repo"]]

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # copy 'resources' folder to path
  resources = system.file('rstudio', 'templates', 'project', 'resources', package = 'worcs', mustWork = TRUE)

  files = list.files(resources, recursive = TRUE, include.dirs = FALSE)
  source = file.path(resources, files)
  target = file.path(path, files)
  file.copy(source, target)

  # write files

  # Begin manuscript
  manuscript_file <- file.path(path, "manuscript.Rmd")
  draft(
    file = manuscript_file,
    "apa6",
    package = "papaja",
    create_dir = FALSE,
    edit = FALSE
  )
  manuscript_text <- readLines(manuscript_file)
  manuscript_text <- append(manuscript_text, "knit              : worcs::cite_all", after = (grep("^---$", manuscript_text)[2]-1))
  manuscript_text <- append(manuscript_text, 'library("worcs")', after = grep('^library\\("papaja"\\)$', manuscript_text))
  writeLines(manuscript_text, manuscript_file)
  # End manuscript


  # Begin prereg
  if(!tolower(prereg_template) == "none"){
  
	draft(
	  file.path(path, "preregistration.Rmd"),
	  paste0(tolower(prereg_template), "_prereg"),
	  package = "prereg",
	  create_dir = FALSE,
	  edit = FALSE
	)

  }
  # End prereg

# Use renv ----------------------------------------------------------------
  norm_path <- normalizePath(path)
  if(use_renv){
    init_fun <- get("init", asNamespace("renv"))
    do.call(init_fun, list(project = norm_path, restart = FALSE))
  }

  #use_git() initialises a Git repository and adds important files to .gitignore. If user consents, it also makes an initial commit.
  #usethis::use_github()
  write(c(".Rhistory",
          ".Rprofile",
          "*.csv",
          "*.sav",
          "*.sas7bdat",
          "*.xlsx",
          "*.xls",
          "*.pdf",
          "*.fff",
          "*.log",
          "*.tex",
          "!checksums.csv"),
        file = file.path(norm_path, ".gitignore"), append = TRUE)
  if(grepl("^https://github.com/.+?/.+?\\.git$", remote_repo)){
    tryCatch({
      git_init(path = norm_path)
      git_remote_add(name = "origin", url = remote_repo)
      git_add(files = "README.md")
      git_commit(message = "worcs template initial commit")
      git_push(remote = "origin")
    }, error = function(e){warning("Could not connect to a remote GitHub repository. You are working with a local git repository only.", call. = FALSE)})
  } else {
    warning("No valid GitHub address provided. You are working with a local git repository only.", call. = FALSE)
  }
}
