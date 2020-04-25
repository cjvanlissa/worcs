#' @importFrom rmarkdown draft
#' @importFrom gert git_init git_remote_add git_add git_commit git_push
#' @importFrom utils installed.packages
# @importFrom renv init
worcs_template <- function(path, ...) {
  # collect inputs
  dots <- list(...)
  prereg_template <- dots[["prereg_template"]]
  add_license <- dots[["add_license"]]
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
  if("papaja" %in% rownames(installed.packages())){
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
  } else {
    message('Could not generate a manuscript file, because the \'papaja\' package is not installed. Run this code to see instructions on how to install this package from GitHub:\n  vignette("setup", package = "worcs") ')
  }
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

  # Begin license
  if(!tolower(add_license) == "none"){
    dir.create(path, recursive = TRUE, showWarnings = FALSE)

    # copy 'resources' folder to path
    license_dir = system.file('rstudio', 'templates', 'project', 'licenses', package = 'worcs', mustWork = TRUE)
    license_file <- file.path(license_dir, paste0(add_license, ".txt"))
    if(file.exists(license_file)){
      file.copy(license_file, file.path(path, "LICENSE"))
    } else {
      warning("Could not find requested license.")
    }
  }
  # End license

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

  # Update readme
  if(file.exists(file.path(norm_path, "README.md"))){
    cont <- readLines(file.path(norm_path, "README.md"))
    f <- list.files(norm_path)
    tab <- matrix(c("File", "Description", "Usage",
                    "README.md", "Description of project", "Human editable"), nrow = 2, byrow = TRUE)
    rproj_name <- paste0(gsub("^.+\\b(.+)$", "\\1", norm_path), ".Rproj")
    cont[grep("You can load this project in Rstudio by opening the file called ", cont)] <- paste0(grep("You can load this project in Rstudio by opening the file called ", cont, value = TRUE), "'", rproj_name, "'.")
    tab <- rbind(tab, c(rproj_name, "Project file", "Loads project"))
    tab <- describe_file("LICENSE", "User permissions", "Read only", tab, norm_path)
    tab <- describe_file("manuscript.rmd", "Source code for paper", "Human editable", tab, norm_path)
    tab <- describe_file("preregistration.rmd", "Preregistered hypotheses", "Human editable", tab, norm_path)
    tab <- describe_file("prepare_data.R", "Script to process raw data", "Human editable", tab, norm_path)
    tab <- describe_file("renv.lock", "Reproducible R environment", "Read only", tab, norm_path)
    tab <- append(apply(tab, 1, paste, collapse = " | "), "--- | --- | ---", after = 1)
    cont <- append(cont, tab, after = grep("You can add rows to this table", cont))
    writeLines(cont, file.path(norm_path, "README.md"))
  }

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
  if("GCtorture" %in% ls()) rm(GCtorture)
}

describe_file <- function(file, desc, usage, tab, norm_path){
  if(file.exists(file.path(norm_path, file))){
    return(rbind(tab, c(file, desc, usage)))
  } else {
    return(tab)
  }
}
