#' @title Create codebook for a dataset
#' @description Creates a codebook for a dataset in 'R Markdown' format, and
#' renders it to 'markdown' for 'GitHub'. Users can customize the 'R Markdown'
#' document and re-knit it, for example, to add a paragraph with details on
#' the data collection procedures. The variable descriptives are stored in
#' a \code{.csv} file, which can be edited in 'R' or a spreadsheet program.
#' Columns can be appended, and we encourage users to complete at least the
#' following two columns in this file:
#' \itemize{
#' \item{category} Describe the type of variable in this column. For example:
#' "morality".
#' \item{description} Provide a plain-text description of the variable. For
#' example, the full text of a questionnaire item: "People should be willing to
#' do anything to help a member of their family".
#' }
#' Re-knitting the 'R Markdown' file (using \code{\link[rmarkdown]{render}}) will
#' transfer these changes to the 'markdown' file for 'GitHub'.
#' @param data A data.frame for which to create a codebook.
#' @param render_file Logical. Whether or not to render the document.
#' @param filename Character. File name to write the codebook \code{rmarkdown}
#' file to.
#' @param csv_file Character. File name to write the codebook \code{rmarkdown}
#' file to. By default, uses the filename stem of the \code{filename} argument.
#' Set to \code{NULL} to write the codebook only to the 'R Markdown' file, and
#' not to \code{.csv}.
#' @return \code{Logical}, indicating whether or not the operation was
#' successful. This function is mostly called for its side effect of rendering
#' an 'R Markdown' codebook.
#' @examples
#' library(rmarkdown)
#' library(knitr)
#' filename <- tempfile("codebook", fileext = ".Rmd")
#' make_codebook(iris, filename = filename, csv_file = NULL)
#' unlink(c(
#'   ".worcs",
#'   filename,
#'   gsub("\\.Rmd", "\\.md", filename),
#'   gsub("\\.Rmd", "\\.html", filename),
#'   gsub("\\.Rmd", "_files", filename)
#' ), recursive = TRUE)
#' @rdname codebook
#' @export
#' @importFrom rmarkdown draft render
#' @importFrom stats median var
#' @importFrom utils capture.output
make_codebook <-
  function(data,
           filename = "codebook.Rmd",
           render_file = TRUE,
           csv_file = gsub("Rmd$", "csv", filename)) {
    filename <- force(filename)
    function_success <- TRUE

    summaries <- do.call(descriptives, list(x = data))
    summaries <- cbind(summaries,
            category = NA,
            description = NA)
    if (file.exists(filename)) {
      col_message(paste0("Removing previous version of '", filename, "'."))
      invisible(file.remove(filename))
    }
    draft(
      filename,
      template = "github_document",
      package = "rmarkdown",
      create_dir = FALSE,
      edit = FALSE
    )
    file_contents <- readLines(filename, encoding = "UTF-8")
    file_contents[grep("^title:", file_contents)[1]] <-
      paste0('title: "Codebook created on ',
             Sys.Date(),
             ' at ',
             Sys.time(),
             '"')
    file_contents[grep("^knitr::opts", file_contents)[1]] <-
      "knitr::opts_chunk$set(echo = FALSE, results = 'asis')"
    file_contents <-
      file_contents[1:(grep("^##", file_contents)[1] - 1)]
    dm <- dim(data)
    checksum <- checksum_data_as_csv(data)
    if (is.null(csv_file)) {
      sum_tab <-
        paste0(c("summaries <- ", capture.output(dput(summaries))))
      #write_worcsfile(".worcs",
      #                codebook = list(rmd_file = filename, checksum = checksum))
    } else {
      if (file.exists(csv_file)) {
        col_message(paste0("Removing previous version of '", csv_file, "'."))
        invisible(file.remove(csv_file))
      }
      write.csv(x = summaries, file = csv_file, row.names = FALSE)
      sum_tab <- c(paste0('summaries <- read.csv("', csv_file, '", stringsAsFactors = FALSE)'),
          "summaries <- summaries[, !colSums(is.na(summaries)) == nrow(summaries)]"
        )
      #write_worcsfile(".worcs",
      #                codebook = list(
      #                  rmd_file = filename,
      #                  csv_file = csv_file,
      #                  checksum = checksum
      #                ))
    }
    function_success <- function_success | tryCatch({
      write(
        c(
          file_contents,
          "## Dataset description",
          paste0("The data contains ", dm[1], " cases and ", dm[2], " variables."),
          "",
          "## Codebook",
          "",
          "```{r}",
          sum_tab,
          "options(knitr.kable.NA = '')",
          "knitr::kable(summaries, row.names = FALSE, digits = 2)",
          "```",
          "",
          "### Legend",
          "",
          "* __Name__: Variable name",
          "* __type__: Data type of the variable",
          "* __missing__: Proportion of missing values for this variable",
          "* __unique__: Number of unique values",
          "* __mean__: Mean value",
          "* __median__: Median value",
          "* __mode__: Most common value (for categorical variables, this shows the frequency of the most common category)",
          "* **mode_value**: For categorical variables, the value of the most common category",
          "* __sd__: Standard deviation (measure of dispersion for numerical variables",
          "* __v__: Agresti's V (measure of dispersion for categorical variables)",
          "* __min__: Minimum value",
          "* __max__: Maximum value",
          "* __range__: Range between minimum and maximum value",
          "* __skew__: Skewness of the variable",
          "* __skew_2se__: Skewness of the variable divided by 2*SE of the skewness. If this is greater than abs(1), skewness is significant",
          "* __kurt__: Kurtosis (peakedness) of the variable",
          "* __kurt_2se__: Kurtosis of the variable divided by 2*SE of the kurtosis. If this is greater than abs(1), kurtosis is significant.",
          "",
          "This codebook was generated using the [Workflow for Open Reproducible Code in Science (WORCS)](https://osf.io/zcvbs/)"
        ),
        filename
      )
      TRUE
    }, error = function(e) {
      return(FALSE)
    })
    if (render_file) {
      function_success <- function_success | tryCatch({
        render(filename)
        TRUE
      }, error = function(e) {
        return(FALSE)
      })
    }
    return(function_success)
  }
