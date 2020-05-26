# Readme <a href='https://osf.io/zcvbs/'><img src='worcs_badge.png' align="right" height="139" /></a>

<!-- Please add a brief introduction to explain what the project is about    -->

## Where do I start?

You can load this project in Rstudio by opening the file called 

## Project structure

<!--  You can add rows to this table, using "|" to separate columns.         -->

<!--  You can consider adding the following to this file:                    -->
<!--  * A citation reference for your project                                -->
<!--  * Contact information for questions/comments                           -->
<!--  * How people can offer to contribute to the project                    -->
<!--  * A contributor code of conduct, https://www.contributor-covenant.org/ -->

# Reproducibility

This project uses the Workflow for Open Reproducible Code in Science (WORCS) to
ensure transparency and reproducibility. The workflow is designed to meet the
principles of Open Science throughout a research project. 

* To learn how WORCS helps researchers meet the TOP-guidelines and FAIR principles, read the preprint at https://osf.io/zcvbs/
* To get started with `worcs`, see the [setup vignette](https://cjvanlissa.github.io/worcs/articles/setup.html)
* For detailed information about the steps of the WORCS workflow, see the [workflow vignette](https://cjvanlissa.github.io/worcs/articles/workflow.html)
* For a brief overview of the steps of the WORCS workflow, see below.

## WORCS: Steps to follow for a project

## Phase 1: Study design

1. Create a new (Public or Private) repository on 'GitHub'
2. Create a new RStudio project using the WORCS template
3. Optional: Preregister your analysis
4. Optional: Upload preregistration to another repository
5. Optional: Add study Materials to the repository

## Phase 2: Data analysis

6. Load the raw data
7. Save the data using `open_data()` or `closed_data()`. Never commit data to 'Git' that you do not intend to share
8. Write the manuscript in `manuscript.Rmd`, using code chunks to perform the analyses.
9. Commit every small change
10. Cite essential references with `@`, and non-essential references with `@@`

## Phase 3: Submission/publication

11. Store the R environment by calling `renv::snapshot()`
12. Optional: Add a WORCS-badge to your README file and complete the optional elements of the WORCS checklist
13. Make the Private 'GitHub' repository Public
14. [Create a project page on the Open Science Framework](https://help.osf.io/hc/en-us/articles/360019737594-Create-a-Project)
15. Connect your 'OSF' project page to the 'GitHub' repository](https://help.osf.io/hc/en-us/articles/360019929813-Connect-GitHub-to-a-Project)
16. Add an open science statement to the Abstract or Author notes, which links to the 'GitHub' repository or 'OSF' page
17. Knit the paper to PDF
18. Optional: Publish a preprint
19. Submit the paper, and tag the release of the submitted paper as in Step 3.

## Notes for cautious researchers

Some researchers might want to share their work only once the paper is accepted for publication. In this case, we recommend creating a "Private" repository in Step 1, and completing Steps 13-18 upon acceptance.
