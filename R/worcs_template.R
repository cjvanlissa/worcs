#' @importFrom rmarkdown draft
#' @importFrom renv init
worcs_template <- function(path, ...) {
  # collect inputs
  dots <- list(...)
  prereg_template <- dots[["prereg_template"]]
  use_renv <- dots[["use_renv"]]
  remote_repo <- dots[["remote_repo"]]

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # copy 'resources' folder to path
  files = list.files('resources', recursive = TRUE, include.dirs = FALSE)
  source = file.path('resources', files)
  target = file.path(path, files)
  file.copy(source, target)

  # write files

  # Begin manuscript
  draft(
    file.path(path, "manuscript.Rmd"),
    "apa6",
    package = "papaja",
    create_dir = FALSE,
    edit = FALSE
  )
  # End manuscript


  # Begin prereg
  draft(
    file.path(path, "preregistration.Rmd"),
    paste0(tolower(prereg_template), "_prereg"),
    package = "prereg",
    create_dir = FALSE,
    edit = FALSE
  )

  # End prereg

# Use renv ----------------------------------------------------------------
  if(use_renv){
    renv_path <- normalizePath(path)
    do.call(init, list(project = renv_path, restart = FALSE))
  }

  #use_git() initialises a Git repository and adds important files to .gitignore. If user consents, it also makes an initial commit.
  #usethis::use_github()
  if(has_git()){
    git_comd <- paste0('git init "', path, '"')
    system(command = git_comd)
    write(c("*.csv",
                 "*.sav",
                 "*.sas7bdat",
                 "*.xlsx",
                 "*.xls",
                 "*.pdf",
                 "!checksums.csv"),
          file = file.path(path, ".gitignore"),
          append = TRUE)
    if(grepl("^https://github.com/.+?/.+?\\.git$", remote_repo)){
      connect_github(remote_repo)
    } else {
      warning("Remote repository address is not valid.")
    }
  } else {
    warning("Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.")
  }
}
