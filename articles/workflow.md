# The WORCS workflow, version 0.1.16

## WORCS: Steps to follow for a project

This vignette describes the Workflow for Open Reproducible Code in
Science, as introduced in Van Lissa et al. (2021). The paper describes
the rationale and principled approach on which the workflow is based;
this vignette describes the practical steps for R-users in greater
detail. Note that, although the steps are numbered for reference
purposes, we acknowledge that the process of conducting research is not
always linear. The workflow is illustrated in the graph below, with
optional steps displayed in blue nodes:

![](workflow.png)

### Phase 1: Study design

1.  Create a new remote repository on a ‘Git’ hosting service, such as
    [“GitHub”](https://github.com)
    - For inexperienced users, we recommend making this repository
      “Private”, which means only you and selected co-authors can access
      it. You can set it to “Public” later - for example, when the paper
      goes to print - and the entire history of the Repository will be
      public record. We recommend making the repository “Public” from
      the start **only if** you are an experienced user and know what
      you are doing.
    - Copy the repository link to clipboard; this link should look
      something like `https://github.com/username/repository.git`
2.  In Rstudio, click File \> New Project \> New directory \> WORCS
    Project Template
    1.  Paste the remote Repository address in the textbox. This address
        should look like `https://github.com/username/repository.git`
    2.  Keep the checkbox for `renv` checked if you want to use
        dependency management (recommended)
    3.  Select a preregistration template, or add a preregistration
        later using
        [`add_preregistration()`](https://cjvanlissa.github.io/worcs/reference/add_preregistration.md)
    4.  Select a manuscript template, or add a manuscript later using
        [`add_manuscript()`](https://cjvanlissa.github.io/worcs/reference/add_manuscript.md)
    5.  Select a license for your project (we recommend a CC-BY license,
        which allows free use of the licensed material as long as the
        creator is credited)
3.  A template README.md file will be automatically generated during
    project creation. Edit this template to explain how users should
    interact with the project. Based on your selections in the New
    Project dialog, a LICENSE will also be added to the project, to
    explain users’ rights and limit your liability. We recommend a CC-BY
    license, which allows free use of the licensed material as long as
    the creator is credited.
4.  Optional: Preregister your analysis by committing a plain-text
    preregistration and [tag this
    commit](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository)
    with the label “preregistration”:
    - Document study plans in a `preregistration.Rmd` file, and
      optionally, planned analyses in a `.R` file.
    - In the top-right panel of ‘RStudio’, select the ‘Git’ tab
    - Select the checkbox next to the preregistration file(s)
    - Click the Commit button.
    - In the pop-up window, write an informative “Commit message”, e.g.,
      “Preregistration”
    - Click the Commit button below the message dialog
    - Click the green arrow labeled “Push” to send your commit to the
      ‘Git’ remote repository
    - [Tag this commit as a
      release](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository)
      on the remote repository, using the label “preregistration”. A
      tagged release helps others retrieve this commit.
    - Instructions for ‘GitHub’ [are explained
      here](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository)
5.  Optional: Render the preregistration to PDF, and upload it as an
    attachment to a dedicated preregistration server like
    AsPredicted.org or OSF.io
    - In ‘RStudio’, with the file ‘preregistration.Rmd’ open, click the
      “Knit” button above the top left panel
    - When the PDF is generated, go to one of the recognized
      preregistration services’ websites, create a new preregistration,
      and upload it as an attachment.
    - Optional: Generate a DOI for the preregistration through [the
      OSF](https://osf.io/) or a service like
      [Zenodo](https://zenodo.org/)
6.  Optional: Add study materials to the repository.
    - Only do this for study materials to which you own the rights, or
      when the materials’ license allows it
    - You can solicit feedback and outside contributions on a ‘Git’
      remote repository by opening an “Issue” or by accepting “Pull
      requests”

### Phase 2: Writing and analysis

7.  Create an executable script documenting the code required to load
    the raw data into a tabular format, and de-identify human subjects
    if applicable
    - Document this preprocessing (“data wrangling”) procedure in the
      `prepare_data.R` file.
    - This file is intended to document steps that can not or should not
      be replicated by end users, unless they have access to the raw
      data file.
    - These are steps you would run only once, the first time you load
      data into R.
    - Make this file as short as possible; only include steps that are
      absolutely necessary
8.  Save the data using
    [`open_data()`](https://cjvanlissa.github.io/worcs/reference/open_data.md)
    or
    [`closed_data()`](https://cjvanlissa.github.io/worcs/reference/closed_data.md)
    - **WARNING:** Once you commit a data file to the ‘Git’ repository,
      its record will be retained forever (unless the entire repository
      is deleted). Assume that pushing data to a ‘Git’ remote repository
      cannot be undone. Follow the mantra: “Never commit something you
      do not intend to share”.
    - When using external data sources (e.g., obtained using an API), it
      is recommended to store a local copy, to make the project portable
      and to ensure that end users have access to the same version of
      the data you used.
9.  Write the manuscript in `Manuscript.Rmd`
    - Use code chunks to perform the analyses. The first code chunk
      should call
      [`load_data()`](https://cjvanlissa.github.io/worcs/reference/load_data.md)
    - Finish each sentence with one carriage return (enter); separate
      paragraphs with a double carriage return.
10. Regularly Commit your progress to the Git repository; ideally, after
    completing each small and clearly defined task.
    - Call
      `git_update("Describe the changes made since the last commit")` to
      Add all new files (not blocked by `.gitignore`), Commit them, and
      Push the changes to a remote repository, all in one step
    - For more control, select the ‘Git’ tab in the top-right panel of
      ‘RStudio’
    - Select the checkboxes next to all files whose changes you wish to
      Commit
    - Click the Commit button.
    - In the pop-up window, write an informative “Commit message”.
    - Click the Commit button below the message dialog
    - Click the green arrow labeled “Push” to send your commit to the
      remote repository
11. While writing, cite essential references with one at-symbol,
    `[@essentialref2020]`, and non-essential references with a double
    at-symbol, `[@@nonessential2020]`.

### Phase 3: Submission and publication

12. Use dependency management to make the computational environment
    fully reproducible. When using `renv`, you can save the state of the
    project library (all packages used) by calling
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).
    This updates the lockfile, `renv.lock`.
13. Optional: Add a WORCS-badge to your project’s README file and
    complete the optional elements of the WORCS checklist to qualify for
    a “Perfect” rating. Run the
    [`check_worcs()`](https://cjvanlissa.github.io/worcs/reference/check_worcs.md)
    function to see whether your project adheres to the WORCS checklist
    (see `worcs::checklist`)
    - This adds a WORCS-badge to your ‘README.md’ file, with a rank of
      “Fail”, “Limited”, or “Open”.
    - Reference the WORCS checklist and your paper’s score in the paper.
    - *Optional:* Complete the additional optional items in the WORCS
      checklist by hand, and get a “Perfect” rating.
14. Make the ‘Git’ remote repository “Public” if it was set to “Private”
    - Instructions for ‘GitHub’:
      - Go to your project’s repository
      - Click the “Settings” button
      - Scroll to the bottom of the page; click “Make public”, and
        follow the on-screen instructions
15. [Create a project on the Open Science Framework
    (OSF)](https://help.osf.io/article/252-create-a-project) and
    [connect it to the ‘Git’ remote
    repository](https://help.osf.io/article/211-connect-github-to-a-project).
    - On the OSF project page, you can select a License for the project.
      This helps clearly communicate the terms of reusability of your
      project. Make sure to use the same License you selected during
      project creation in Step 3.
16. Generate a Digital Object Identifier (DOI) for the project on
    [OSF](https://osf.io/)
    - A DOI is a persistent identifier that can be used to link to your
      project page.
    - You may have already created a project page under Step 5 if you
      preregistered on the OSF
    - Alternatively, you can connect your ‘Git’ remote repository to
      [Zenodo](https://zenodo.org/), instead of the OSF, to create DOIs
      for the project and specific resources.
17. Add an open science statement to the Abstract or Author notes, which
    links to the ‘OSF’ project page and/or the ‘Git’ remote repository.
    - Placing this statement in the Abstract or Author note means that
      readers can find your project even if the paper is published
      behind a paywall.
    - The link can be masked for blind review.
    - The open science statement should indicate which resources are
      available in the online repository; data, code, materials, study
      design details, a pre-registration, and/or comprehensive
      citations. For further guidance, see Aalbersberg et al. (2018).
      Example:  
      *In the spirit of open science, an online repository is available
      at XXX, which contains \[the data/a synthetic data file\],
      analysis code, the research materials used, details about the
      study design, more comprehensive citations, and a tagged release
      with the preregistration.*
18. Knit the paper to PDF for submission
    - In ‘RStudio’, with the file ‘manuscript.Rmd’ open, click the
      “Knit” button above the top left panel
    - To retain essential citations only, change the front matter of the
      ‘manuscript.Rmd’ file:  
      Change `knit: worcs::cite_all` to `knit: worcs::cite_essential`
19. Optional: [Publish preprint in a not-for-profit preprint repository
    such as PsyArchiv, and connect it to your existing OSF
    project](https://help.osf.io/article/177-upload-a-preprint)
    - Check [Open Policy Finder](https://openpolicyfinder.jisc.ac.uk/)
      to be sure that your intended outlet allows the publication of
      preprints; many journals do, nowadays - and if they do not, it is
      worth considering other outlets.
20. Submit the paper, and [tag the commit of the submitted paper as a
    release](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository),
    as in Step 4.

### Notes for cautious researchers

Some researchers might want to share their work only once the paper is
accepted for publication. In this case, we recommend creating a
“Private” repository in Step 1, and completing Steps 13-18 upon
acceptance by the journal.

**Image attribution**

The [Git Logo](https://git-scm.com/) by Jason Long is licensed under the
Creative Commons Attribution 3.0 Unported License. The [OSF
logo](https://osf.io/) is licensed under CC0 1.0 Universal. Icons in the
workflow graph are obtained from Flaticon; see [detailed
attribution](https://github.com/cjvanlissa/worcs/blob/master/paper/workflow_graph/Attribution_for_images.txt).

## Sample WORCS projects

For a list of sample `worcs` projects created by the authors and other
users, see the [`README.md` file on the WORCS GitHub
page](https://github.com/cjvanlissa/worcs). This list is regularly
updated.

**References**

Aalbersberg, IJsbrand Jan, Tom Appleyard, Sarah Brookhart, Todd
Carpenter, Michael Clarke, Stephen Curry, Josh Dahl, et al. 2018.
“Making Science Transparent By Default; Introducing the TOP Statement,”
February. <https://doi.org/10.31219/osf.io/sm78t>.

Van Lissa, Caspar J., Andreas M. Brandmaier, Loek Brinkman, Anna-Lena
Lamprecht, Aaron Peikert, Marijn E. Struiksma, and Barbara M. I. Vreede.
2021. “WORCS: A Workflow for Open Reproducible Code in Science.” *Data
Science* 4 (1): 29–49. <https://doi.org/10.3233/DS-210031>.
