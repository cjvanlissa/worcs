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
#' 'R Markdown' manuscript. Default: 'APA6'. Available choices include
#' \code{APA6} from the \code{papaja} package,
#' a \code{\link[rmarkdown]{github_document}}, and templates included in the
#' \code{\link[rticles:rticles]{rticles}} package.
#' For more information, see \code{\link{add_manuscript}}.
#' @param preregistration Character, indicating what template to use for the
#' preregistration. Default: 'cos_prereg'. Available choices include:
#' \code{"PSS", "Secondary", "None"}, and all templates from the
#' \code{\link[prereg:prereg]{prereg}} package. For more information, see
#' \code{\link{add_preregistration}}.
#' @param add_license Character, indicating what license to include.
#' Default: 'CC_BY_4.0'. Available options include:
#' \code{"CC_BY_4.0", "CC_BY-SA_4.0", "CC_BY-NC_4.0", "CC_BY-NC-SA_4.0",
#' "CC_BY-ND_4.0", "CC_BY-NC-ND_4.0", "None"}. For more information, see
#' <https://creativecommons.org/licenses/>.
#' @param use_renv Logical, indicating whether or not to use 'renv' to make the
#' project reproducible. Default: TRUE. See \code{\link[renv]{init}}.
#' @param use_targets Logical, indicating whether or not to use 'targets' to
#' create a Make-like pipeline. Default: FALSE See \code{\link[targets]{targets-package}}.
#' @param remote_repo Character, address of the remote repository for
#' this project. This link should have the form
#' \code{https://github.com[username][repo].git} (preferred) or
#' \code{git@[...].git} (if using SSH).
#' If a valid remote repository link is provided, a commit will
#' be made containing the 'README.md' file, and will be pushed to the remote
#' repository. Default: 'https'.
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
worcs_project <- function(path = "worcs_project", manuscript = "APA6", preregistration = "cos_prereg", add_license = "CC_BY_4.0", use_renv = TRUE, use_targets = FALSE, remote_repo = "https", verbose = TRUE, ...) {
  cl <- match.call(expand.dots = FALSE)

  # collect inputs
  manuscript <- tolower(manuscript)
  # Write code for use_targets such that it works with target_markdown and normal targets
  if(manuscript == "target_markdown") use_targets <- TRUE
  preregistration <- tolower(preregistration)
  add_license <- tolower(add_license)
  dots <- list(...)
  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  path <- normalizePath(path)
  # Check if valid Git signature exists
  if("use_git" %in% names(dots)){
    use_git <- dots[["use_git"]]
  } else {
    use_git <- has_git()
  }
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
  switch(manuscript,
         "none" = {
           write_as_utf(recommend_data, file.path(path, "run_me.R"))
           write_worcsfile(filename = file.path(path, ".worcs"),
                           entry_point = "run_me.R",
                           modify = TRUE)
           add_recipe(worcs_directory = path,
                      recipe = "source('run_me.R')")
         },
         # "target_markdown" = {
         #
         # },
         {
           cl[[1L]] <- quote(worcs::add_manuscript)
           names(cl)[which(names(cl) == "path")] <- "worcs_directory"
           eval(cl, parent.frame())
           add_recipe(worcs_directory = path)
         })

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
      file.copy(license_file, file.path(path, "LICENSE"), copy.mode = FALSE)
      col_message("Writing license file.", verbose = verbose)
    }, error = function(e){
      col_message("Writing license file.", success = FALSE)
    })
  }
  # End license


# Use targets -------------------------------------------------------------
  if(use_targets){
    # tryCatch({
    if(requireNamespace("targets", quietly = TRUE) & requireNamespace("tarchetypes", quietly = TRUE)){
      worcs::add_targets(worcs_directory = path, verbose = verbose)
      # names(cl)[which(names(cl) == "path")] <- "worcs_directory"
      # eval(cl, parent.frame())
      col_message("Initializing 'targets' for a Make-like pipeline.", verbose = verbose)
    }
    # }, error = function(e){
    #   col_message("Could not initialize 'targets'.", success = FALSE)
    # })
  }

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
  repo_url <- parse_repo(remote_repo = remote_repo, verbose = verbose)
  valid_repo <- !is.null(repo_url)
  if(use_git & valid_repo){
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
    }, error = function(e){
      col_message("Could not connect to a remote 'GitHub' repository. You are working with a local 'Git' repository only.", success = FALSE, verbose = verbose)
      })
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

create_man_targets <- function(remote_repo, worcs_directory){
  if(requireNamespace("targets", quietly = TRUE)) {
    run_in_worcsdir(targets::use_targets_rmd(open = FALSE), worcs_directory = worcs_directory)
    # run_in_worcsdir(rmarkdown::render(man_fn_rel), worcs_directory = worcs_directory)
    return()
  }
  #   manuscript_text <- readLines(man_fn_abs, encoding = "UTF-8")
  #   # Add bibliography
  #   bib_line <- which(startsWith(manuscript_text, "bibliography"))[1]
  #   manuscript_text[bib_line] <- append_yaml(manuscript_text[bib_line], "bibliography", "references.bib")
  #   # Add citation function
  #   add_lines <- c(
  #     "knit              : worcs::cite_all"
  #   )
  #   manuscript_text <- append(manuscript_text, add_lines, after = (grep("^---$", manuscript_text)[2]-1))
  #   # Add call to library("worcs")
  #   manuscript_text <- append(manuscript_text, recommend_data, after = grep('^library\\("papaja"\\)$', manuscript_text))
  #
  #   # Add introductory sentence
  #   add_lines <- c(
  #     "",
  #     paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [WORCS version ",
  #            gsub("^(\\d{1,}(\\.\\d{1,}){2}).+$", "\\1", as.character(packageVersion("worcs"))),
  #            ", @vanlissaWORCSWorkflowOpen2021] to ensure reproducibility and transparency. All code <!--and data--> are available at ",
  #            ifelse(is.null(remote_repo), "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
  #     "",
  #     "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2021]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
  #     "",
  #     "<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->",
  #     "`r notify_synthetic()`"
  #   )
  #   manuscript_text <- append(manuscript_text, add_lines, after = grep('^```', manuscript_text)[2])
  #
  #   # Write
  #   write_as_utf(manuscript_text, man_fn_abs)
  # } else {
  #   col_message('Could not generate an APA6 manuscript file, because the \'papaja\' package is not installed. Run this code to see instructions on how to install this package from GitHub:\n  vignette("setup", package = "worcs")', success = FALSE)
  # }
}


create_man_papaja <- function(man_fn_abs, remote_repo){
  if(requireNamespace("papaja", quietly = TRUE)) {
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

    manuscript_text[bib_line] <- append_yaml(yaml_text = manuscript_text[bib_line], yaml_command = "bibliography", add_this = "references.bib")

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
             ", @vanlissaWORCSWorkflowOpen2021] to ensure reproducibility and transparency. All code <!--and data--> are available at ",
             ifelse(is.null(remote_repo), "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2021]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      "",
      "<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->",
      "`r notify_synthetic()`"
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

    repo_address <- remote_repo
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
    repo_url <- parse_repo(remote_repo = remote_repo, verbose = FALSE)
    valid_repo <- !is.null(repo_url)
    add_lines <- c(
      "",
      paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [@vanlissaWORCSWorkflowOpen2021] to ensure reproducibility and transparency. All code <!--and data--> are available at ",
             ifelse(is.null(remote_repo), "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2021]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      "",
      "<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->",
      "`r notify_synthetic()`"
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
      paste0("This manuscript uses the Workflow for Open Reproducible Code in Science [@vanlissaWORCSWorkflowOpen2021] to ensure reproducibility and transparency. All code <!--and data--> are available at ",
             ifelse(is.null(remote_repo), "<!--insert repository URL-->", paste0("<", remote_repo, ">")), "."),
      "",
      "This is an example of a non-essential citation [@@vanlissaWORCSWorkflowOpen2021]. If you change the rendering function to `worcs::cite_essential`, it will be removed.",
      "",
      "<!--The function below inserts a notification if the manuscript is knit using synthetic data. Make sure to insert it after load_data().-->",
      "`r notify_synthetic()`"
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
  file.copy(source, target, copy.mode = FALSE)
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
#' \code{"APA6", "github_document", "None"} and the templates from the
#' \code{\link[rticles:rticles]{rticles}} package. See Details.
#' @param remote_repo Character, 'https' link to the remote repository for
#' this project. This link should have the form \code{https://[...].git}.
#' This link will be inserted in the draft manuscript.
#' @param verbose Logical. Whether or not to print messages to the console
#' during project creation. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @details Available choices include the following manuscript templates:
#' \describe{
#'   \item{\code{'APA6'}}{An APA6 style template from the \code{papaja} package}
#'   \item{\code{'github_document'}}{A \code{\link[rmarkdown]{github_document}} from the \code{rmarkdown} package}
#'   \item{\code{'acm_article'}}{acm style template from the \code{rtices} package}
#'   \item{\code{'acs_article'}}{acs style template from the \code{rtices} package}
#'   \item{\code{'aea_article'}}{aea style template from the \code{rtices} package}
#'   \item{\code{'agu_article'}}{agu style template from the \code{rtices} package}
#'   \item{\code{'ajs_article'}}{ajs style template from the \code{rtices} package}
#'   \item{\code{'amq_article'}}{amq style template from the \code{rtices} package}
#'   \item{\code{'ams_article'}}{ams style template from the \code{rtices} package}
#'   \item{\code{'arxiv_article'}}{arxiv style template from the \code{rtices} package}
#'   \item{\code{'asa_article'}}{asa style template from the \code{rtices} package}
#'   \item{\code{'bioinformatics_article'}}{bioinformatics style template from the \code{rtices} package}
#'   \item{\code{'biometrics_article'}}{biometrics style template from the \code{rtices} package}
#'   \item{\code{'copernicus_article'}}{copernicus style template from the \code{rtices} package}
#'   \item{\code{'ctex_article'}}{ctex style template from the \code{rtices} package}
#'   \item{\code{'elsevier_article'}}{elsevier style template from the \code{rtices} package}
#'   \item{\code{'frontiers_article'}}{frontiers style template from the \code{rtices} package}
#'   \item{\code{'glossa_article'}}{glossa style template from the \code{rtices} package}
#'   \item{\code{'ieee_article'}}{ieee style template from the \code{rtices} package}
#'   \item{\code{'ims_article'}}{ims style template from the \code{rtices} package}
#'   \item{\code{'informs_article'}}{informs style template from the \code{rtices} package}
#'   \item{\code{'iop_article'}}{iop style template from the \code{rtices} package}
#'   \item{\code{'isba_article'}}{isba style template from the \code{rtices} package}
#'   \item{\code{'jasa_article'}}{jasa style template from the \code{rtices} package}
#'   \item{\code{'jedm_article'}}{jedm style template from the \code{rtices} package}
#'   \item{\code{'joss_article'}}{joss style template from the \code{rtices} package}
#'   \item{\code{'jss_article'}}{jss style template from the \code{rtices} package}
#'   \item{\code{'lipics_article'}}{lipics style template from the \code{rtices} package}
#'   \item{\code{'mdpi_article'}}{mdpi style template from the \code{rtices} package}
#'   \item{\code{'mnras_article'}}{mnras style template from the \code{rtices} package}
#'   \item{\code{'oup_article'}}{oup style template from the \code{rtices} package}
#'   \item{\code{'peerj_article'}}{peerj style template from the \code{rtices} package}
#'   \item{\code{'pihph_article'}}{pihph style template from the \code{rtices} package}
#'   \item{\code{'plos_article'}}{plos style template from the \code{rtices} package}
#'   \item{\code{'pnas_article'}}{pnas style template from the \code{rtices} package}
#'   \item{\code{'rjournal_article'}}{rjournal style template from the \code{rtices} package}
#'   \item{\code{'rsos_article'}}{rsos style template from the \code{rtices} package}
#'   \item{\code{'rss_article'}}{rss style template from the \code{rtices} package}
#'   \item{\code{'sage_article'}}{sage style template from the \code{rtices} package}
#'   \item{\code{'sim_article'}}{sim style template from the \code{rtices} package}
#'   \item{\code{'springer_article'}}{springer style template from the \code{rtices} package}
#'   \item{\code{'tf_article'}}{tf style template from the \code{rtices} package}
#'   \item{\code{'trb_article'}}{trb style template from the \code{rtices} package}
#'   \item{\code{'wellcomeor_article'}}{wellcomeor style template from the \code{rtices} package}
#' }
# p <- ls(asNamespace("rticles"))
# p <- p[endsWith(p, "_article")]
# out <- c(
#   "\\itemize{",
#   "  \\item{\\code{'APA6'}}{A \\code{\\link[papaja:papaja]{APA6}} style template from the \\code{papaja} package}",
#   "  \\item{\\code{'github_document'}}{A \\code{\\link[rmarkdown]{github_document}} from the \\code{rmarkdown} package}",
#   paste0("  \\item{\\code{'", p, "'}}{", gsub("_article", "", p, fixed = TRUE), " style template from the \\code{rtices} package}"),
#   "}"
# )
# out <- paste0("#' ", out)
# cat(out, sep = '\n', file = "clipboard")
## !!!ALSO ADD THEM TO THE PROJECT TEMPLATE FILE WORCS.DCF!!!!
# cat(p, sep = ', ', file = "clipboard")
#' @return No return value. This function is called for its side effects.
#' @examples
#' the_test <- "worcs_manuscript"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' file.create(file.path(tempdir(), the_test, ".worcs"))
#' add_manuscript(file.path(tempdir(), the_test),
#'               manuscript = "None")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname add_manuscript
#' @export
#' @importFrom rmarkdown draft
#' @importFrom prereg vantveer_prereg
# @importFrom renv init
add_manuscript <- function(worcs_directory = ".", manuscript = "APA6", remote_repo = NULL, verbose = TRUE, ...) {
  # collect inputs
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")

  manuscript <- tolower(manuscript)
  dots <- list(...)
  # ensure path exists
  worcs_directory <- normalizePath(worcs_directory)
  # Check if valid Git signature exists
  #remote_repo <- parse_repo(remote_repo = remote_repo, verbose = verbose)

  # Begin manuscript
    tryCatch({
      # Construct path to filename and create directory
      man_dir_rel <- "manuscript"
      man_dir_abs <- file.path(worcs_directory, man_dir_rel)
      man_fn_rel <- file.path(man_dir_rel, "manuscript.Rmd")
      man_fn_abs <- file.path(man_dir_abs, "manuscript.Rmd")
      dir.create(man_dir_abs)
      if(manuscript == "apa6"){
        create_man_papaja(man_fn_abs, remote_repo = remote_repo)
      }
      if(manuscript == "target_markdown"){
        unlink(man_dir_abs, recursive = TRUE)
        man_dir_abs <- worcs_directory
        man_dir_rel <- "."
        create_man_targets(remote_repo = remote_repo, worcs_directory = worcs_directory)
      }
      # all_rticles <- ls(asNamespace("rticles"))
      # all_rticles <- all_rticles[endsWith(all_rticles, "_article")]
      # dput(all_rticles, "clipboard")
      if(endsWith(manuscript, "_article")){
        manuscript <- gsub("_article", "", manuscript, fixed = TRUE)
        create_man_rticles(man_fn_abs, manuscript, remote_repo = remote_repo)
      }
      if(manuscript == "github_document"){
        create_man_github(man_fn_abs, remote_repo = remote_repo)
      }

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
#' preregistration. Default: \code{"cos_prereg"}; use \code{"None"} to omit a
#' preregistration. See Details for other available choices.
#' @param verbose Logical. Whether or not to print messages to the console
#' during project creation. Default: TRUE
#' @param ... Additional arguments passed to and from functions.
#' @return No return value. This function is called for its side effects.
#' @details Available choices include the templates from the
#' \code{\link[prereg:prereg]{prereg}} package, and several unique templates
#' included with \code{worcs}:
# p <- ls(asNamespace("prereg"))
# p <- p[endsWith(p, "_prereg")]
# out <- c(
#   "\\itemize{",
#   "  \\item{\\code{'PSS'}}{Preregistration and Sharing Software (Krypotos,",
#   "  Klugkist, Mertens, & Engelhard, 2019)}",
#   "  \\item{\\code{'Secondary'}}{Preregistration for secondary analyses (Mertens &",
#   "  Krypotos, 2019)}",
#   paste0("  \\item{\\code{'", p, "'}}{", gsub("_prereg", "", p, fixed = TRUE), " template from the \\code{prereg} package}"),
#   "}"
# )
# out <- paste0("#' ", out)
# cat(out, sep = '\n', file = "clipboard")
## !!!ALSO ADD THEM TO THE PROJECT TEMPLATE FILE WORCS.DCF!!!!
# cat(p, sep = ', ', file = "clipboard")
#' \describe{
#'   \item{\code{'PSS'}}{Preregistration and Sharing Software (Krypotos,
#'   Klugkist, Mertens, & Engelhard, 2019)}
#'   \item{\code{'Secondary'}}{Preregistration for secondary analyses (Mertens &
#'   Krypotos, 2019)}
#'   \item{\code{'aspredicted_prereg'}}{aspredicted template from the \code{prereg} package}
#'   \item{\code{'brandt_prereg'}}{brandt template from the \code{prereg} package}
#'   \item{\code{'cos_prereg'}}{cos template from the \code{prereg} package}
#'   \item{\code{'fmri_prereg'}}{fmri template from the \code{prereg} package}
#'   \item{\code{'prp_quant_prereg'}}{prp_quant template from the \code{prereg} package}
#'   \item{\code{'psyquant_prereg'}}{psyquant template from the \code{prereg} package}
#'   \item{\code{'rr_prereg'}}{rr template from the \code{prereg} package}
#'   \item{\code{'vantveer_prereg'}}{vantveer template from the \code{prereg} package}
#' }
#' @examples
#' the_test <- "worcs_prereg"
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), the_test))
#' file.create(file.path(tempdir(), the_test, ".worcs"))
#' add_preregistration(file.path(tempdir(), the_test),
#'                     preregistration = "cos_prereg")
#' setwd(old_wd)
#' unlink(file.path(tempdir(), the_test))
#' @rdname add_preregistration
#' @export
#' @importFrom rmarkdown draft
#' @importFrom prereg vantveer_prereg
add_preregistration <- function(worcs_directory = ".",
                                preregistration = "cos_prereg",
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
      p <- ls(asNamespace("prereg"))
      if(paste0(preregistration, "_prereg") %in% p) preregistration <- paste0(preregistration, "_prereg")
      if(endsWith(preregistration, "_prereg")){
        draft(
          file.path(worcs_directory, "preregistration.Rmd"),
          preregistration,
          package = "prereg",
          create_dir = FALSE,
          edit = FALSE
        )
      }

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

append_yaml <- function(yaml_text, yaml_command, add_this){
  this_line <- grep(paste0("^\\s{0,}", yaml_command, "\\s{0,}:"), yaml_text)[1]
  gsub(':.*$', paste0(': [', paste0(
    dQuote(c(add_this,
             trimws(gsub('"', "", strsplit(gsub("^.+?:", "", yaml_text[this_line]), ",")[[1]]))), q = FALSE), collapse = ", "), ']'), yaml_text[this_line])
}
