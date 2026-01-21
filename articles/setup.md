# Setting up your computer for WORCS

This is a tutorial on how to set up your personal computer for use with
the `worcs` package. It guides you through the installation of several
software packages, and registration on GitHub. This vignette does not
assume a prior installation of `R`, so it is suitable for novice users.
You only have to perform these steps once for every computer you intend
to use `R` and `worcs` on, and the entire process should take
approximately 30 minutes if you start from scratch. In case some of the
software is already installed on your system, you can skip those related
steps.

Follow these steps in order:

1.  Install [R (free)](https://CRAN.R-project.org)
2.  Install [‘RStudio’ Desktop
    (Free)](https://posit.co/download/rstudio-desktop/)
3.  Install Git from [git-scm.com](https://git-scm.com/downloads). Use
    the default, recommended settings. It is especially important to
    leave these settings selected:
    - Git from the command line and also from third party software  
    - Use the ‘OpenSSL’ library  
    - Checkout Windows-style, commit Unix-style line endings  
    - Enable Git Credential Manager  
    - If you run into any trouble, a more comprehensive tutorial on
      installing Git is available at
      [happygitwithr.com](https://happygitwithr.com/install-git.html).
4.  Register on ‘GitHub’ (alternatively: see [this
    vignette](https://cjvanlissa.github.io/worcs/articles/git_cloud.html)
    on how to use ‘GitLab’ or ‘Bitbucket’)
    - Go to [github.com](https://github.com/) and click *Sign up*.
      Choose an “Individual”, “Free” plan.
5.  Install all packages required for WORCS by running the code block
    below this writing in the ‘RStudio’ console. Be prepared for three
    contingencies:
    - If you receive any error saying *There is no package called
      \[package name\]*, then run the code
      `install.packages("package name")`  
    - If you are prompted to update packages, just press \[ENTER\] to
      avoid updating packages. Updating packages this way in an
      interactive session sometimes leads to errors if the packages are
      loaded.  
    - If you see a pop-up dialog asking *Do you want to install from
      sources the package which needs compilation?*, click *No*.

&nbsp;

    install.packages("worcs", dependencies = TRUE)
    tinytex::install_tinytex()
    renv::consent(provided = TRUE)

6.  Connect ‘RStudio’ to Git and GitHub (for more support, see [Happy
    Git with R](https://happygitwithr.com/)
    1.  Open ‘RStudio’, open the Tools menu, click *Global Options*, and
        click *Git/SVN*
    2.  Verify that *Enable version control interface for RStudio
        projects* is selected
    3.  Verify that *Git executable:* shows the location of git.exe. If
        it is missing, manually fix the location of the file.
    4.  Restart your computer
    5.  Run
        [`usethis::create_github_token()`](https://usethis.r-lib.org/reference/github-token.html).
        This should open a webpage with a dialog that allows you to
        create a Personal Access Token (PAT) to authorize your computer
        to exchange information with your GitHub account. The default
        settings are fine; just click “Generate Token” (bottom of the
        page).
    6.  Copy the generated PAT to your clipboard (NOTE: You will not be
        able to view it again!)
    7.  Run
        [`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html).
        This should open a dialog in the R console that allows you to
        paste the PAT from your clipboard.
    8.  If you do not have a Git user set up on your computer yet (e.g.,
        if this is the first time you will be using Git), run the
        following - making sure to substitute your actual username and
        email:

&nbsp;

    worcs::git_user("your_name", "your_email", overwrite = TRUE)

7.  Everything should be installed and connected now. You can verify
    your installation using an automated test suite. The results will be
    printed to the console; if any tests fail, you will see a hint for
    how to resolve it. Run the code below this writing in the ‘RStudio’
    console:

&nbsp;

    worcs::check_worcs_installation()

### Optional step

If you intend to write documents in APA style, you should additionally
install the `papaja` package. Because `papaja` has many dependencies, it
is recommended to skip this step if you intend to write documents in a
different style than APA. Unfortunately, this package is not yet
available on the central R repository CRAN, but you can install it from
‘GitHub’ using the following code:

    install.packages("papaja", dependencies = TRUE, update = "never")
