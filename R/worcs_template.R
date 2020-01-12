#' @importFrom rmarkdown draft
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
    "manuscript.Rmd",
    "apa6",
    package = "papaja",
    create_dir = FALSE,
    edit = FALSE
  )
  # End manuscript


  # Begin prereg
  draft(
    "preregistration.Rmd",
    paste0(tolower(prereg_template), "_prereg"),
    package = "prereg",
    create_dir = FALSE,
    edit = FALSE
  )

  # End prereg


  # Begin data
data_txt <- c("# In this file, write the R-code necessary to load your original data file",
"# (e.g., an SPSS, Excel, or SAS-file), and convert it to a data.frame. Then,",
"# use the function open_data(your_data_frame) or closed_data(your_data_frame)",
"# to store the data.")
  # End data
  writeLines(data_txt, con = file.path(path, "prepare_data.R"))


# Use renv ----------------------------------------------------------------
  if(use_renv) renv::init(project = path)

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
                 "!checksums.csv"),  ".gitignore", append = TRUE)
  } else {
    warning("Rstudio is not yet connected to Git. You will not be able to use the worcs package yet.")
  }
}
