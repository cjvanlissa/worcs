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
principles of Open Science throughout a research project. For more details,
please read the preprint at https://osf.io/zcvbs/

## WORCS: Steps to follow for a project

### Study design phase

1. Create a new Private repository on github, copy the https:// link to clipboard  
  The link should look something like https://github.com/yourname/yourrepo.git
2. In Rstudio, click File > New Project > New directory > WORCS Project Template
    a. Paste the GitHub Repository address in the textbox
    b. Keep the checkbox for `renv` checked if you want to document all dependencies (recommended)
    c. Select a preregistration template
3. Write the preregistration `.Rmd`
4. In the top-right corner of Rstudio, select the Git tab, select the checkboxes next to all files, and click the Commit button. Write an informative message for the commit, e.g., "Preregistration", again click Commit, and then click the green Push arrow to send your commit to GitHub
5. Go to the GitHub repository for this project, and tag the Commit as a preregistration
6. Optional: Render the preregistration to PDF, and upload it to AsPredicted.org or OSF.io as an attachment
7. Optional: Add study Materials (to which you own the rights) to the repository. It is possible to solicit feedback (by opening a GitHub Issue) and acknowledge outside contributions (by accepting Pull requests)

### Data analysis phase

8. Read the data into R, and document this procedure in `prepare_data.R`
9. Use `open_data()` or `closed_data()` to store the data
10. Write the manuscript in `Manuscript.Rmd`, using code chunks to perform the analyses.
11. Regularly commit your progress to the Git repository; ideally, after completing each small and clearly defined task. Use informative commit messages. Push the commits to GitHub.
12. Cite essential references with one at-symbol (`[@essentialref2020]`), and non-essential references with a double at-symbol (`[@@nonessential2020]`).

### Submission phase

13. To save the state of the project library (all packages used), call `renv::snapshot()`. This updates the lockfile, `renv.lock`.
14. To render the paper with essential citations only for submission, change the line `knit: worcs::cite_all` to `knit: worcs::cite_essential`. Then, press the Knit button to generate a PDF

### Publication phase

13. Make the GitHub repository public
14. [Create an OSF project](https://help.osf.io/hc/en-us/articles/360019737594-Create-a-Project); although you may have already done this in Step 6.
15. [Connect your GitHub repository to the OSF project](https://help.osf.io/hc/en-us/articles/360019929813-Connect-GitHub-to-a-Project)
16. Add an Open Science statement to the manuscript, with a link to the OSF project
17. Optional: [Publish preprint in a not-for-profit preprint repository such as PsyArchiv, and connect it to your existing OSF project](https://help.osf.io/hc/en-us/articles/360019930533-Upload-a-Preprint)
    + Check [Sherpa Romeo](http://sherpa.ac.uk/romeo/index.php) to be sure that your intended outlet allows the publication of preprints; many journals do, nowadays - and if they do not, it is worth considering other outlets.
