#' @title Create codebook for a dataset
#' @description Creates a codebook for a dataset in 'Rmarkdown' format, and
#' renders it to 'markdown' for 'GitHub'. Users can customize the 'Rmarkdown'
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
#' Re-knitting the 'Rmarkdown' file (using \code{\link[rmarkdown]{render}}) will
#' transfer these changes to the 'markdown' file for 'GitHub'.
#' @param data A data.frame for which to create a codebook.
#' @param render_file Logical. Whether or not to render the document.
#' @param filename Character. File name to write the codebook \code{rmarkdown}
#' file to.
#' @param csv_file Character. File name to write the codebook \code{rmarkdown}
#' file to. By default, uses the filename stem of the \code{filename} argument.
#' Set to \code{NULL} to write the codebook only to the 'Rmarkdown' file, and
#' not to \code{.csv}.
#' @return \code{Logical}, indicating whether or not the operation was
#' succesful. This function is mostly called for its side effect of rendering an
#' \code{rmarkdown} codebook.
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

#' @title Describe a dataset
#' @description Provide descriptive statistics for a dataset.
#' @param x An object for which a method exists.
#' @return A \code{data.frame} with descriptive statistics for \code{x}.
#' @examples
#' descriptives(iris)
#' @rdname descriptives
#' @export
descriptives <- function(x) {
  UseMethod("descriptives", x)
}

#' @method descriptives data.frame
#' @export
descriptives.data.frame <- function(x) {
  data_types <-
    sapply(x, function(i) {
      paste0(class(i), collapse = ", ")
    })
  out <- lapply(x, descriptives)
  all_names <-
    c(
      "missing",
      "unique",
      "mean",
      "median",
      "mode",
      "mode_value",
      "sd",
      "v",
      "min",
      "max",
      "range",
      "skew",
      "skew_2se",
      "kurt",
      "kurt_2se"
    )
  out <-
    do.call(rbind, c(lapply(out, function(x)
      data.frame(c(
        x, sapply(setdiff(all_names, names(x)),
                  function(y)
                    NA)
      ))),
      make.row.names = FALSE))
  out <- out[, all_names]

  out <- cbind(name = names(x),
               type = data_types,
               out)
  rownames(out) <- NULL
  out
}

#' @method descriptives numeric
#' @export
descriptives.numeric <- function(x) {
  rng <- range(x, na.rm = TRUE)
  sk <- skew_kurtosis(x)
  cbind(
    data.frame(
      missing = sum(is.na(x)) / length(x),
      unique = length(unique(x)),
      mean = mean(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      mode = median(x, na.rm = TRUE),
      sd = mean(x, na.rm = TRUE),
      min = rng[1],
      max = rng[2],
      range = diff(rng)
    ),
    t(sk)
  )
}

#' @method descriptives integer
#' @export
descriptives.integer <- descriptives.numeric

#' @method descriptives default
#' @export
descriptives.default <- function(x) {
  if(!is.vector(x)) x <- tryCatch(as.vector(x), error = function(e){NA})
  tb <- tryCatch(table(x), error = function(e){NA})
  data.frame(
    missing = tryCatch({sum(is.na(x)) / length(x)}, error = function(e){NA}),
    unique = tryCatch(length(tb), error = function(e){NA}),
    mode = tryCatch(tb[which.max(tb)], error = function(e){NA}),
    mode_value = tryCatch(names(tb)[which.max(tb)], error = function(e){NA}),
    v = tryCatch(var_cat(x), error = function(e){NA})
  )
}

#' @method descriptives factor
#' @export
descriptives.factor <- descriptives.default

# Agresti's V for categorical data variability
# Agresti, Alan (1990). Categorical Data Analysis. John Wiley and Sons, Inc. 24-25
var_cat <- function(x) {
  x <- x[!is.na(x)]
  if (!length(x))
    return(NA)
  p <- prop.table(table(x))
  #-1 * sum(p*log(p)) Shannon entropy
  1 - sum(p ^ 2)
}

#' @title Calculate skew and kurtosis
#' @description Calculate skew and kurtosis, standard errors for both, and the
#' estimates divided by two times the standard error. If this latter quantity
#' exceeds an absolute value of 1, the skew/kurtosis is significant. With very
#' large sample sizes, significant skew/kurtosis is common.
#' @param x An object for which a method exists.
#' @param verbose Logical. Whether or not to print messages to the console,
#' Default: FALSE
#' @param se Whether or not to return the standard errors, Default: FALSE
#' @param ... Additional arguments to pass to and from functions.
#' @return A \code{matrix} of skew and kurtosis statistics for \code{x}.
#' @examples
#' skew_kurtosis(datasets::anscombe)
#' @rdname skew_kurtosis
#' @export
skew_kurtosis <- function(x, verbose = FALSE, se = FALSE, ...) {
  UseMethod("skew_kurtosis", x)
}

#' @method skew_kurtosis data.frame
#' @export
skew_kurtosis.data.frame <-
  function(x, verbose = FALSE, se = FALSE, ...) {
    t(sapply(x, skew_kurtosis))
  }

#' @method skew_kurtosis matrix
#' @export
skew_kurtosis.matrix <-
  function(x, verbose = FALSE, se = FALSE, ...) {
    t(apply(x, 2, skew_kurtosis))
  }

#' @method skew_kurtosis numeric
#' @export
skew_kurtosis.numeric <-
  function(x, verbose = FALSE, se = FALSE, ...) {
    x <- x[!is.na(x)]
    n <- length(x)
    out <- rep(NA, 6)
    names(out) <-
      c("skew", "skew_se", "skew_2se", "kurt", "kurt_se", "kurt_2se")
    if (n > 3) {
      if (n > 5000 &
          verbose)
        message("Sample size > 5000; skew and kurtosis will likely be significant.")
      skew <- sum((x - mean(x)) ^ 3) / (n * sqrt(var(x)) ^ 3)
      skew_se <- sqrt(6 * n * (n - 1) / (n - 2) / (n + 1) / (n + 3))
      skew_2se <- skew / (2 * skew_se)
      kurt <- sum((x - mean(x)) ^ 4) / (n * var(x) ^ 2) - 3
      kurt_se <- sqrt(24 * n * ((n - 1) ^ 2) / (n - 3) / (n - 2) / (n + 3) /
                        (n + 5))
      kurt_2se <- kurt / (2 * kurt_se)
      out <-
        c(
          skew = skew,
          skew_se = skew_se,
          skew_2se = skew_2se,
          kurt = kurt,
          kurt_se = kurt_se,
          kurt_2se = kurt_2se
        )
    }
    if (se) {
      return(out)
    } else {
      return(out[c(1, 3, 4, 6)])
    }
  }

#' @method skew_kurtosis default
#' @export
skew_kurtosis.default <-
  function(x, verbose = FALSE, se = FALSE, ...) {
    out <- rep(NA, 6)
    names(out) <-
      c("skew", "skew_se", "skew_2se", "kurt", "kurt_se", "kurt_2se")
    if (se) {
      return(out)
    } else {
      return(out[c(1, 3, 4, 6)])
    }
  }


col_message <- function(..., col = 30, success = TRUE) {
  #94
  #cat(paste0("\033[0;", col, "m",txt,"\033[0m","\n"))
  txt <- do.call(paste0, list(...))
  cat(paste0(
    ifelse(success,
           "\033[0;32mv  \033[0m",
           "\033[0;31mX  \033[0m"),
    "\033[0;",
    col,
    "m",
    txt,
    "\033[0m",
    "\n"
  ))
}
