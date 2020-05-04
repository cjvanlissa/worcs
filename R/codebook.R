#' @title Create codebook for a dataset
#' @description Creates a rudimentary 'Rmarkdown' codebook for a dataset, and
#' renders it to markdown for 'GitHub'. Users can customize the 'Rmarkdown'
#' document, for example, by adding a column with variable descriptions, or a
#' paragraph with details on the data collection procedure.
#' @param data A data.frame for which to create a codebook.
#' @param render_file Logical. Whether or not to render the document.
#' @return \code{Logical}, indicating whether or not the operation was
#' succesful. This function is mostly called for its side effect of rendering an
#' \code{rmarkdown} codebook.
#' @examples
#' library(rmarkdown)
#' library(knitr)
#' old_wd <- getwd()
#' dir.create(file.path(tempdir(), "codebook"))
#' setwd(file.path(tempdir(), "citeall"))
#' make_codebook(iris)
#' setwd(old_wd)
#' unlink(file.path(tempdir(), "citeall"))
#' @rdname codebook
#' @export
#' @importFrom rmarkdown draft render
#' @importFrom stats median var
#' @importFrom utils capture.output
make_codebook <- function(data, render_file = TRUE){
  function_success <- TRUE
  data_types <- sapply(data, function(x){paste0(class(x), collapse = ", ")})
  summaries <- descfun(data)
  summaries <- cbind(
    name = names(data),
    type = data_types,
    summaries
  )
  if(file.exists("codebook.Rmd")){
    message("Removing previous version of 'codebook.Rmd'.")
    invisible(file.remove("codebook.Rmd"))
  }
  draft("codebook.Rmd",
                   template = "github_document",
                   package = "rmarkdown",
                   create_dir = FALSE,
                   edit = FALSE)
  file_contents <- readLines("codebook.Rmd")
  file_contents[grep("^title:", file_contents)[1]] <- paste0('title: "Codebook created on ', Sys.Date(), ' at ', Sys.time(), '"')
  file_contents[grep("^knitr::opts", file_contents)[1]] <- "knitr::opts_chunk$set(echo = FALSE, results = 'asis')"
  file_contents <- file_contents[1:(grep("^##", file_contents)[1]-1)]
  dm <- dim(data)
  sum_tab <- capture.output(dput(summaries))
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
        "summaries <- ",
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
        "* __V__: Agresti's V (measure of dispersion for categorical variables",
        "* __min__: Minimum value",
        "* __max__: Maximum value",
        "* __range__: Range between minimum and maximum value",
        "* __skew__: Skewness of the variable",
        "* __skew_2se__: Skewness of the variable divided by 2*SE of the skewness. If this is greater than abs(1), skewness is significant",
        "* __kurt__: Kurtosis (peakedness) of the variable",
        "* __kurt_2se__: Kurtosis of the variable divided by 2*SE of the kurtosis. If this is greater than abs(1), kurtosis is significant."
      ),
      "codebook.Rmd"
    )
    TRUE
  }, error = function(e) {
    return(FALSE)
  })
  if(render_file){
    function_success <- function_success | tryCatch({
      render("codebook.Rmd")
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
#' descfun(iris)
#' @rdname descfun
#' @export
descfun <- function(x){
  UseMethod("descfun", x)
}

#' @method descfun data.frame
#' @export
descfun.data.frame <- function(x){
  out <- lapply(x, descfun)
  all_names <- c("missing", "unique", "mean", "median", "mode", "mode_value", "sd", "V", "min", "max", "range", "skew", "skew_2se", "kurt", "kurt_2se")
  out <-
    do.call(rbind, c(lapply(out, function(x)
      data.frame(c(
        x, sapply(setdiff(all_names, names(x)),
                  function(y)
                    NA)
      ))),
      make.row.names = FALSE))
  out[, all_names]
}

#' @method descfun numeric
#' @export
descfun.numeric <- function(x){
  rng <- range(x, na.rm = TRUE)
  sk <- skew_kurtosis(x)
  cbind(data.frame(
    missing = sum(is.na(x))/length(x),
    unique = length(unique(x)),
    mean = mean(x, na.rm = TRUE),
    median = median(x, na.rm = TRUE),
    mode = median(x, na.rm = TRUE),
    sd = mean(x, na.rm = TRUE),
    min = rng[1],
    max = rng[2],
    range = diff(rng)
  ), t(sk))
}

#' @method descfun integer
#' @export
descfun.integer <- descfun.numeric

#' @method descfun default
#' @export
descfun.default <- function(x){
  tb <- table(x)
  data.frame(
    missing = sum(is.na(x))/length(x),
    unique = length(unique(x)),
    mode = tb[which.max(tb)],
    mode_value = names(tb)[which.max(tb)],
    V = V(x)
  )
}

# Agresti's V for categorical data variability
# Agresti, Alan (1990). Categorical Data Analysis. John Wiley and Sons, Inc. 24-25
V <- function(x){
  x <- x[!is.na(x)]
  if(!length(x)) return(NA)
  p <- prop.table(table(x))
  #-1 * sum(p*log(p)) Shannon entropy
  1-sum(p^2)
}

#' @title Calculate skew and kurtosis
#' @description Calculate skew and kurtosis, standard errors for both, and the
#' estimates divided by two times the standard error. If this latter quantity
#' exceeds an absolute value of 1, the skew/kurtosis is significant. With very
#' large sample sizes, significant skew/kurtosis is common.
#' @param x An object for which a method exists.
#' @param verbose Whether or not to print messages to the console,
#' Default: FALSE
#' @param se Whether or not to return the standard errors, Default: FALSE
#' @param ... Additional arguments to pass to and from functions.
#' @return A \code{matrix} of skew and kurtosis statistics for \code{x}.
#' @examples
#' skew_kurtosis(datasets::anscombe)
#' @rdname skew_kurtosis
#' @export
skew_kurtosis <- function(x, verbose = FALSE, se = FALSE, ...){
  UseMethod("skew_kurtosis", x)
}

#' @method skew_kurtosis data.frame
#' @export
skew_kurtosis.data.frame <- function(x, verbose = FALSE, se = FALSE, ...){
  t(sapply(x, skew_kurtosis))
}

#' @method skew_kurtosis matrix
#' @export
skew_kurtosis.matrix <- function(x, verbose = FALSE, se = FALSE, ...){
  t(apply(x, 2, skew_kurtosis))
}

#' @method skew_kurtosis numeric
#' @export
skew_kurtosis.numeric <- function(x, verbose = FALSE, se = FALSE, ...){
  x <- x[!is.na(x)]
  n <- length(x)
  out <- rep(NA, 6)
  names(out) <- c("skew", "skew_se", "skew_2se", "kurt", "kurt_se", "kurt_2se")
  if(n > 3){
    if(n > 5000 & verbose) message("Sample size > 5000; skew and kurtosis will likely be significant.")
    skew <- sum((x-mean(x))^3)/(n*sqrt(var(x))^3)
    skew_se <- sqrt(6*n*(n-1)/(n-2)/(n+1)/(n+3))
    skew_2se <- skew/(2*skew_se)
    kurt <- sum((x-mean(x))^4)/(n*var(x)^2) - 3
    kurt_se <- sqrt(24*n*((n-1)^2)/(n-3)/(n-2)/(n+3)/(n+5))
    kurt_2se <- kurt/(2*kurt_se)
    out <- c(skew = skew, skew_se = skew_se, skew_2se = skew_2se, kurt = kurt, kurt_se = kurt_se, kurt_2se = kurt_2se)
  }
  if(se){
    return(out)
  } else {
    return(out[c(1,3,4,6)])
  }
}

#' @method skew_kurtosis default
#' @export
skew_kurtosis.default <- function(x, verbose = FALSE, se = FALSE, ...){
  out <- rep(NA, 6)
  names(out) <- c("skew", "skew_se", "skew_2se", "kurt", "kurt_se", "kurt_2se")
  if(se){
    return(out)
  } else {
    return(out[c(1,3,4,6)])
  }
}
