recommend_data <- c('library("worcs")',
                    "# We recommend that you prepare your raw data for analysis in 'prepare_data.R',",
                    "# and end that file with either open_data(yourdata), or closed_data(yourdata).",
                    "# Then, uncomment the line below to load the original or synthetic data",
                    "# (whichever is available), to allow anyone to reproduce your code:",
                    "# load_data()")

#' @title Create new WORCS project
#' @description Creates a new 'worcs' project. This function is invoked by
#' the 'RStudio' project template manager, but can also be called directly to
#' create a WORCS project through syntax or the console.
#' @param path Character, indicating the directory in which to create the
#' 'worcs' project. Default: 'worcs_project'.
#' @param manuscript Character, indicating what template to use for the
#' 'R Markdown' manuscript. Default: 'APA6'. Available choices include:
#' \code{"APA6", "github_document", "None", "ams_article", "asa_article",
#' "biometrics_article", "copernicus_article", "ctex", "elsevier_article",
#' "frontiers_article", "ieee_article", "joss_article", "jss_article",
#' "mdpi_article", "mnras_article", "oup_article", "peerj_article",
#' "plos_article", "pnas_article", "rjournal_article", "rsos_article",
#' "sage_article", "sim_article", "springer_article", "tf_article"}.
#' For more information, see \code{\link{add_manuscript}}.
#' @param preregistration Character, indicating what template to use for the
#' preregistration. Default: 'COS'. Available choices include:
#' \code{"COS", "VantVeer", "Brandt", "AsPredicted", "PSS", "Secondary",
#' "None"}. For more information, see \code{\link{add_preregistration}}.
#' @param add_license Character, indicating what license to include.
#' Default: 'CC_BY_4.0'. Available options include:
#' \code{"CC_BY_4.0", "CC_BY-SA_4.0", "CC_BY-NC_4.0", "CC_BY-NC-SA_4.0",
#' "CC_BY-ND_4.0", "CC_BY-NC-ND_4.0", "None"}. For more information, see
#' <https://creativecommons.org/licenses/>.
#' @param use_renv Logical, indicating whether or not to use 'renv' to make the
#' project reproducible. Default: TRUE. See \code{\link[renv]{init}}.
#' @param remote_repo Character, 'https' link to the remote repository for
#' this project. This link should have the form \code{https://[...].git}.
#' If a valid remote repository link is provided, a commit will
#' be made containing the 'README.md' file, and will be pushed to the remote
#' repository. Default: 'https'. When no 'https' address is provided, an 'SSH'
#' address of the form \code{git@[...].git} is also accepted.
#' @param verbose Logical. Whether or not to print messages to the console
#' during project creation. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @return No return value. This function is called for its side effects.
#' @examples
#' the_test <- "worcs_template"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' do.call(git_user, worcs:::get_user())
#' worcs_project(file.path(tempdir(), the_test, "worcs_project"),
#'               manuscript = "github_document",
#'               preregistration = "None",
#'               add_license = "None",
#'               use_renv = FALSE,
#'               remote_repo = "https")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname worcs_project
#' @export
#' @importFrom rmarkdown draft
#' @importFrom gert git_init git_remote_add git_add git_commit git_push
#' @importFrom utils installed.packages packageVersion
#' @importFrom prereg vantveer_prereg
#' @importFrom methods formalArgs
# @importFrom renv init
worcs_project <- function(path = "worcs_project", manuscript = "APA6", preregistration = "COS", add_license = "CC_BY_4.0", use_renv = TRUE, remote_repo = "https", verbose = TRUE, ...) {
  cl <- match.call(expand.dots = FALSE)

  # collect inputs
  manuscript <- tolower(manuscript)
  preregistration <- tolower(preregistration)
  add_license <- tolower(add_license)
  dots <- list(...)
  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  path <- normalizePath(path)
  # Check if valid Git signature exists
  use_git <- has_git()
  if(!use_git){
    col_message("Could not find a working installation of 'Git', which is required to safeguard the transparency and reproducibility of your project. Please connect 'Git' by following the steps described in this vignette:\n  vignette('setup', package = 'worcs')", success = FALSE)
  } else {
    col_message("Initializing 'Git' repository.", verbose = verbose)
    git_init(path = path)
  }

  # Create .worcs file
  tryCatch({
    write_worcsfile(filename = file.path(path, ".worcs"),
                    worcs_version = as.character(packageVersion("worcs")),
                    creator = Sys.info()["effective_user"]
    )
    col_message("Writing '.worcs' file.", verbose = verbose)
  }, error = function(e){
    col_message("Writing '.worcs' file.", success = FALSE)
  })


  # copy 'resources' folder to path
  tryCatch({
    copy_resources(which_files = c(
      "README.md",
      "prepare_data.R",
      "worcs_icon.png"
    ), path = path)
    col_message("Copying standard files.", verbose = verbose)
  }, error = function(e){
    col_message("Copying standard files.", success = FALSE)
  })


  # write files

  # Begin manuscript
  if(!manuscript == "none"){
    cl[[1L]] <- quote(worcs::add_manuscript)
    names(cl)[which(names(cl) == "path")] <- "worcs_directory"
    eval(cl, parent.frame())
  } else {
    write_as_utf(recommend_data, file.path(path, "run_me.R"))
    write_worcsfile(filename = file.path(path, ".worcs"),
                    entry_point = "run_me.R",
                    modify = TRUE)
  }
  # End manuscript


  # Begin prereg
  if(!preregistration == "none"){
    cl[[1L]] <- quote(worcs::add_preregistration)
    names(cl)[which(names(cl) == "path")] <- "worcs_directory"
    eval(cl, parent.frame())
  }
  # End prereg

  # Begin license
  if(!add_license == "none"){
    tryCatch({
      dir.create(path, recursive = TRUE, showWarnings = FALSE)

      # copy 'resources' folder to path
      license_dir = system.file('rstudio', 'templates', 'project', 'licenses', package = 'worcs', mustWork = TRUE)
      license_file <- file.path(license_dir, paste0(add_license, ".txt"))
      file.copy(license_file, file.path(path, "LICENSE"))
      col_message("Writing license file.", verbose = verbose)
    }, error = function(e){
      col_message("Writing license file.", success = FALSE)
    })
  }
  # End license

# Use renv ----------------------------------------------------------------
  if(use_renv){
    tryCatch({
      init_fun <- get("init", asNamespace("renv"))
      do.call(init_fun, list(project = path, restart = FALSE))
      col_message("Initializing 'renv' for a reproducible R environment.", verbose = verbose)
    }, error = function(e){
      col_message("Initializing 'renv' for a reproducible R environment.", success = FALSE)
    })
  }

  #use_git() initialises a Git repository and adds important files to .gitignore. If user consents, it also makes an initial commit.

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
          "*.tex"),
        file = file.path(path, ".gitignore"), append = TRUE)

  # Update readme
  if(file.exists(file.path(path, "README.md"))){
    cont <- readLines(file.path(path, "README.md"), encoding = "UTF-8")
    f <- list.files(path)
    tab <- matrix(c("File", "Description", "Usage",
                    "README.md", "Description of project", "Human editable"), nrow = 2, byrow = TRUE)
    rproj_name <- paste0(basename(path), ".Rproj")
    cont[which(startsWith(cont, "You can load this project in RStudio by opening the file"))] <- paste0("You can load this project in RStudio by opening the file called '", rproj_name, "'.")
    tab <- rbind(tab, c(rproj_name, "Project file", "Loads project"))
    tab <- describe_file("LICENSE", "User permissions", "Read only", tab, path)
    tab <- describe_file(".worcs", "WORCS metadata YAML", "Read only", tab, path)
    tab <- describe_file("preregistration.rmd", "Preregistered hypotheses", "Human editable", tab, path)
    tab <- describe_file("prepare_data.R", "Script to process raw data", "Human editable", tab, path)
    tab <- describe_file("manuscript/manuscript.rmd", "Source code for paper", "Human editable", tab, path)
    tab <- describe_file("manuscript/references.bib", "BibTex references for manuscript", "Human editable", tab, path)
    tab <- describe_file("renv.lock", "Reproducible R environment", "Read only", tab, path)

    tab <- nice_tab(tab)
    cont <- append(cont, tab, after = grep("You can add rows to this table", cont))
    write_as_utf(cont, file.path(path, "README.md"))
  }

  # Create first commit
  if(use_git){
    tryCatch({
    git_add(files = "README.md", repo = path)
    git_commit(message = "worcs template initial commit", repo = path)
    col_message("Creating first commit (committing README.md).", verbose = verbose)
    }, error = function(e){
      col_message("Creating first commit (committing README.md).", success = FALSE)
    })
  }

  # Connect to remote repo if possible
  if(use_git & endsWith(remote_repo, ".git") &
     (startsWith(remote_repo, "https://") | startsWith(remote_repo, "git@"))){
    tryCatch({
      # For compatibility with old and new gert, check which formals it has
      Args_gert <- list(
        "origin",
        url = remote_repo,
        repo = path
      )
      if("remote" %in% formalArgs(git_remote_add)){
        names(Args_gert)[1] <- "remote"
      } else {
        names(Args_gert)[1] <- "name"
      }
      do.call(git_remote_add, Args_gert)
      git_push(remote = "origin", repo = path)
      col_message(paste0("Connected to remote repository at ", remote_repo), verbose = verbose)
    }, error = function(e){col_message("Could not connect to a remote 'GitHub' repository. You are working with a local 'Git' repository only.", success = FALSE, verbose = verbose)})
  } else {
    col_message("No valid 'GitHub' address provided. You are working with a local 'Git' repository only.", success = FALSE)
  }
  if("GCtorture" %in% ls()) rm("GCtorture")
}

describe_file <- function(file, desc, usage, tab, path){
  if(file.exists(file.path(path, file))){
    return(rbind(tab, c(file, desc, usage)))
  } else {
    return(tab)
  }
}


create_man_papaja <- function(man_fn_abs, remote_repo){
  if("papaja" %in% rownames(installed.packages())){
    draft(
      file = man_fn_abs,
      "apa6",
      package = "papaja",
      create_dir = FALSE,
      edit = FALSE
    )
    manuscript_text <- readLines(man_fn_abs, encoding = "UTF-8")
    # Add bibliography
    bib_line <- which(startsWith(manuscript_text, "bibliography"))[1]
    manuscript_text[bib_line] <- paste0(substr(manuscript_text[bib_line], start = 1, stop = nchar(manuscript_text[bib_line])-1), ', "references.bib"]')
    # Add citation function
    add_lines <- c(
      "knit              : worcs::cite_all"
    )
    manuscript_text <- append(manuscript_text, add_lines, after = (grep("^---$", manuscript_text)[2]-1))
    # Add call to library("worcs")
    manuscript_text <- append(manuscript_text, recommend_data, after = grep('^library\\("papaja"\\)$', manuscript_text))

    # Add introductory sentence
    add_lines <- c(
      "",
      paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [WORCS version ",
             gsub("^(\\d{1,}(\\.\\d{1,}){2}).+$", "\\1", as.character(packageVersion("worcs"))),
             ", @vanlissaWORCSWorkflowOpen2020] to ensure reproducibility and transparency. All code <!--and data--> are available at ", ifelse(remote_repo == "https", "<!--insert repository URL-->", paste0("<", gsub("\\.git$", "", remote_repo), ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2020]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      ""
    )
    manuscript_text <- append(manuscript_text, add_lines, after = grep('^```', manuscript_text)[2])

    # Write
    write_as_utf(manuscript_text, man_fn_abs)
  } else {
    col_message('Could not generate an APA6 manuscript file, because the \'papaja\' package is not installed. Run this code to see instructions on how to install this package from GitHub:\n  vignette("setup", package = "worcs")', success = FALSE)
  }
}

create_man_github <- function(man_fn_abs, remote_repo){
    draft(
      file = man_fn_abs,
      template = "github_document",
      package = "rmarkdown",
      create_dir = FALSE,
      edit = FALSE
    )
    manuscript_text <- readLines(man_fn_abs, encoding = "UTF-8")
    # Add bibliography and citation function
    add_lines <- c(
      "date: '`r format(Sys.time(), \"%d %B, %Y\")`'",
      "bibliography: references.bib",
      "knit: worcs::cite_all"
    )
    manuscript_text <- append(manuscript_text, add_lines, after = (grep("^---$", manuscript_text)[2]-1))
    # Add call to library("worcs")
    manuscript_text <- append(manuscript_text, recommend_data, after = grep('^```', manuscript_text)[1])
    # Add introductory sentence
    add_lines <- c(
      "",
      paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [@vanlissaWORCSWorkflowOpen2020] to ensure reproducibility and transparency. All code <!--and data--> are available at ", ifelse(remote_repo == "https", "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2020]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      ""
    )
    manuscript_text <- append(manuscript_text, add_lines, after = grep('^```', manuscript_text)[2])
    # Write
    write_as_utf(manuscript_text, man_fn_abs)
}

#' @importFrom rticles acm_article
create_man_rticles <- function(man_fn_abs, template, remote_repo){
  if("rticles" %in% rownames(installed.packages())){
    draft(
      file = man_fn_abs,
      template = template,
      package = "rticles",
      create_dir = FALSE,
      edit = FALSE
    )
    manuscript_text <- readLines(man_fn_abs, encoding = "UTF-8")
    # Add bibliography
    bib_line <- which(startsWith(manuscript_text, "bibliography"))[1]
    manuscript_text[bib_line] <- "bibliography: references.bib"

    # Add citation function
    add_lines <- c(
      "knit: worcs::cite_all"
    )
    manuscript_text <- append(manuscript_text, add_lines, after = (grep("^---$", manuscript_text)[2]-1))
    # Add call to library("worcs")
    add_lines <- c(
      '```{r, echo = FALSE, eval = TRUE, message = FALSE}',
      recommend_data,
      '```',
      "",
      paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [@vanlissaWORCSWorkflowOpen2020] to ensure reproducibility and transparency. All code <!--and data--> are available at ", ifelse(remote_repo == "https", "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2020]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      ""
    )
    manuscript_text <- append(manuscript_text, add_lines, after = (grep("^---$", manuscript_text)[2]))
    write_as_utf(manuscript_text, man_fn_abs)
  } else {
    col_message(paste0('Could not generate ', template, ' manuscript file, because the \'rticles\' package is not installed. Run this code to install the package from CRAN:\n  install.packages("rticles", dependencies = TRUE)'), success = FALSE)
  }
}

copy_resources <- function(which_files, path){
  resources <- system.file('rstudio', 'templates', 'project', 'resources', package = 'worcs', mustWork = TRUE)
  files <- list.files(resources, recursive = TRUE, include.dirs = FALSE)
  files <- files[files %in% which_files]
  source <- file.path(resources, files)
  target <- file.path(path, files)
  file.copy(source, target)
}

nice_tab <- function(tab){
  tab <- apply(tab, 2, function(i){
    sprintf(paste0("%-", max(nchar(i)), "s"), i)
  })
  tab <- rbind(tab, sapply(tab[1,], function(i){
    paste0(rep("-", nchar(i)), collapse = "")
  }))
  tab <- tab[c(1, nrow(tab), 2:(nrow(tab)-1)), ]
  apply(tab, 1, paste, collapse = " | ")
}

#' @title Add Rmarkdown manuscript
#' @description Adds an Rmarkdown manuscript to a 'worcs' project.
#' @param worcs_directory Character, indicating the directory
#' in which to create the manuscript files. Default: '.', which points to the
#' current working directory.
#' @param manuscript Character, indicating what template to use for the
#' 'R Markdown' manuscript. Default: 'APA6'. Available choices include:
#' \code{"APA6", "github_document", "None", "ams_article", "asa_article",
#' "biometrics_article", "copernicus_article", "ctex", "elsevier_article",
#' "frontiers_article", "ieee_article", "joss_article", "jss_article",
#' "mdpi_article", "mnras_article", "oup_article", "peerj_article",
#' "plos_article", "pnas_article", "rjournal_article", "rsos_article",
#' "sage_article", "sim_article", "springer_article", "tf_article"}.
#' For more information about \code{APA6}, see the 'papaja' package, at
#' <https://github.com/crsh/papaja>.
#' For more information about \code{github_document}, see
#' \code{\link[rmarkdown]{github_document}}. The remaining formats are
#' documented in the 'rticles' package.
#' @param remote_repo Character, 'https' link to the remote repository for
#' this project. This link should have the form \code{https://[...].git}.
#' This link will be inserted in the draft manuscript.
#' @param verbose Logical. Whether or not to print messages to the console
#' during project creation. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @return No return value. This function is called for its side effects.
#' @examples
#' the_test <- "worcs_manuscript"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' file.create(file.path(tempdir(), the_test, ".worcs"))
#' add_manuscript(file.path(tempdir(), the_test),
#'               manuscript = "github_document")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname add_manuscript
#' @export
#' @importFrom rmarkdown draft
#' @importFrom prereg vantveer_prereg
# @importFrom renv init
add_manuscript <- function(worcs_directory = ".", manuscript = "APA6", remote_repo = "https", verbose = TRUE, ...) {
  # collect inputs
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")

  manuscript <- tolower(manuscript)
  dots <- list(...)
  # ensure path exists
  worcs_directory <- normalizePath(worcs_directory)
  # Check if valid Git signature exists

  # Begin manuscript
    tryCatch({
      # Construct path to filename and create directory
      man_dir_rel <- "manuscript"
      man_dir_abs <- file.path(worcs_directory, man_dir_rel)
      man_fn_rel <- file.path(man_dir_rel, "manuscript.Rmd")
      man_fn_abs <- file.path(man_dir_abs, "manuscript.Rmd")
      dir.create(man_dir_abs)
      switch(manuscript,
             apa6 = create_man_papaja(man_fn_abs, remote_repo = remote_repo),
             acm_article = create_man_rticles(man_fn_abs, "acm_article", remote_repo = remote_repo),
             acs_article = create_man_rticles(man_fn_abs, "acs_article", remote_repo = remote_repo),
             aea_article = create_man_rticles(man_fn_abs, "aea_article", remote_repo = remote_repo),
             agu_article = create_man_rticles(man_fn_abs, "agu_article", remote_repo = remote_repo),
             amq_article = create_man_rticles(man_fn_abs, "amq_article", remote_repo = remote_repo),
             ams_article = create_man_rticles(man_fn_abs, "ams_article", remote_repo = remote_repo),
             asa_article = create_man_rticles(man_fn_abs, "asa_article", remote_repo = remote_repo),
             biometrics_article = create_man_rticles(man_fn_abs, "biometrics_article", remote_repo = remote_repo),
             copernicus_article = create_man_rticles(man_fn_abs, "copernicus_article", remote_repo = remote_repo),
             ctex = create_man_rticles(man_fn_abs, "ctex", remote_repo = remote_repo),
             elsevier_article = create_man_rticles(man_fn_abs, "elsevier_article", remote_repo = remote_repo),
             frontiers_article = create_man_rticles(man_fn_abs, "frontiers_article", remote_repo = remote_repo),
             ieee_article = create_man_rticles(man_fn_abs, "ieee_article", remote_repo = remote_repo),
             joss_article = create_man_rticles(man_fn_abs, "joss_article", remote_repo = remote_repo),
             jss_article = create_man_rticles(man_fn_abs, "jss_article", remote_repo = remote_repo),
             mdpi_article = create_man_rticles(man_fn_abs, "mdpi_article", remote_repo = remote_repo),
             mnras_article = create_man_rticles(man_fn_abs, "mnras_article", remote_repo = remote_repo),
             oup_article = create_man_rticles(man_fn_abs, "oup_article", remote_repo = remote_repo),
             peerj_article = create_man_rticles(man_fn_abs, "peerj_article", remote_repo = remote_repo),
             plos_article = create_man_rticles(man_fn_abs, "plos_article", remote_repo = remote_repo),
             pnas_article = create_man_rticles(man_fn_abs, "pnas_article", remote_repo = remote_repo),
             rjournal_article = create_man_rticles(man_fn_abs, "rjournal_article", remote_repo = remote_repo),
             rsos_article = create_man_rticles(man_fn_abs, "rsos_article", remote_repo = remote_repo),
             sage_article = create_man_rticles(man_fn_abs, "sage_article", remote_repo = remote_repo),
             sim_article = create_man_rticles(man_fn_abs, "sim_article", remote_repo = remote_repo),
             springer_article = create_man_rticles(man_fn_abs, "springer_article", remote_repo = remote_repo),
             tf_article = create_man_rticles(man_fn_abs, "tf_article", remote_repo = remote_repo),
             create_man_github(man_fn_abs, remote_repo = remote_repo)
      )
      # Add references.bib
      copy_resources(which_files = "references.bib", path = man_dir_abs)
      bibfiles <- list.files(path = man_dir_abs, pattern = ".bib$", full.names = TRUE)
      if(length(bibfiles) > 1){
        worcs_ref <- readLines(bibfiles[endsWith(bibfiles, "references.bib")], encoding = "UTF-8")
        bib_text <- do.call(c, lapply(bibfiles[!endsWith(bibfiles, "references.bib")], readLines, encoding = "UTF-8"))
        invisible(file.remove(bibfiles))
        write_as_utf(c(worcs_ref, bib_text), file.path(man_dir_abs, "references.bib"))
      }
      write_worcsfile(filename = fn_worcs,
                      entry_point = man_fn_rel,
                      modify = TRUE)
      col_message("Creating manuscript files.", verbose = verbose)
    }, error = function(e){
      col_message("Creating manuscript files.", success = FALSE)
    })
  # End manuscript
}


#' @title Add Rmarkdown preregistration
#' @description Adds an Rmarkdown preregistration template to a 'worcs' project.
#' @param worcs_directory Character, indicating the directory
#' in which to create the manuscript files. Default: '.', which points to the
#' current working directory.
#' @param preregistration Character, indicating what template to use for the
#' preregistration. Default: \code{"COS"}; use \code{"None"} to omit a
#' preregistration. See Details for other available choices.
#' @param verbose Logical. Whether or not to print messages to the console
#' during project creation. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @return No return value. This function is called for its side effects.
#' @details Available choices include the templates
#' \code{"COS", "VantVeer", "Brandt", "AsPredicted"}, which are imported from the
#' \code{\link[prereg]{cos_prereg}} package, and documented there. Furthermore,
#' several unique templates are included with \code{worcs}:
#' \itemize{
#'   \item{\code{"PSS"}}{Preregistration and Sharing Software (Krypotos,
#'   Klugkist, Mertens, & Engelhard, 2019)}
#'   \item{\code{"Secondary"}}{Preregistration for secondary analyses (Mertens &
#'   Krypotos, 2019)}
#' }
#' @examples
#' the_test <- "worcs_prereg"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' file.create(file.path(tempdir(), the_test, ".worcs"))
#' add_preregistration(file.path(tempdir(), the_test),
#'                     preregistration = "COS")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname add_preregistration
#' @export
#' @importFrom rmarkdown draft
#' @importFrom prereg vantveer_prereg
add_preregistration <- function(worcs_directory = ".",
                                preregistration = "COS",
                                verbose = TRUE,
                                ...) {
  # collect inputs
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  #fn_worcs <- file.path(dn_worcs, ".worcs")
  worcs_directory <- normalizePath(dn_worcs)
  preregistration <- tolower(preregistration)
  #dots <- list(...)

  # Begin preregistration
  tryCatch({
    # Different handling for prereg preregistrations and those included in worcs
    if(!preregistration %in% c("pss", "secondary")){
      draft(
        file.path(worcs_directory, "preregistration.Rmd"),
        paste0(preregistration, "_prereg"),
        package = "prereg",
        create_dir = FALSE,
        edit = FALSE
      )
    } else {
      if(file.exists(paste0(preregistration, ".Rmd"))|file.exists("preregistration.Rmd")){
        stop("Preregistration already exists.")
      } else {
        copy_resources(paste0(preregistration, ".Rmd"), worcs_directory)
        file.rename(paste0(preregistration, ".Rmd"), "preregistration.Rmd")
      }
    }
    col_message("Creating preregistration files.", verbose = verbose)
  }, error = function(e){
    col_message("Creating preregistration files.", success = FALSE)
  })
  # End preregistration
}
