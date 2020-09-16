#' @title Describe a dataset
#' @description Provide descriptive statistics for a dataset.
#' @param x An object for which a method exists.
#' @param ... Additional arguments.
#' @return A \code{data.frame} with descriptive statistics for \code{x}.
#' @examples
#' descriptives(iris)
#' @rdname descriptives
#' @export
#' @importFrom stats median sd
descriptives <- function(x, ...) {
  UseMethod("descriptives", x)
}

#' @method descriptives matrix
#' @export
descriptives.matrix <- function(x, ...) {
  Args <- as.list(match.call()[-1])
  Args$x <- data.frame(x)
  do.call(descriptives, Args)
}

#' @method descriptives data.frame
#' @export
descriptives.data.frame <- function(x, ...) {
  data_types <-
    sapply(x, function(i) {
      paste0(class(i), collapse = ", ")
    })
  out <- lapply(x, descriptives)
  all_names <-
    c(
      "n",
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
descriptives.numeric <- function(x, ...) {
  rng <- range(x, na.rm = TRUE)
  sk <- skew_kurtosis(x)
  cbind(
    data.frame(
      n = sum(!is.na(x)),
      missing = sum(is.na(x))/length(x),
      unique = length(unique(x)),
      mean = mean(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      mode = median(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
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
descriptives.default <- function(x, ...) {
  if(is.factor(x)) x <- droplevels(x)
  if(!is.vector(x)) x <- tryCatch(as.vector(x), error = function(e){NA})
  tb <- tryCatch(table(x, useNA = "always"), error = function(e){NA})
  data.frame(
    n = tryCatch({sum(!is.na(x))}, error = function(e){NA}),
    missing = sum(is.na(x))/length(x),
    unique = tryCatch(length(tb), error = function(e){NA}),
    mode = tryCatch({
      unname(tb[which.max(tb)])
    }, error = function(e){NA}),
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

#' @method skew_kurtosis matrix
#' @export
skew_kurtosis.matrix <-
  function(x, verbose = FALSE, se = FALSE, ...) {
    Args <- as.list(match.call()[-1])
    Args$x <- data.frame(x)
    do.call(skew_kurtosis, Args)
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
    out <- tryCatch({
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
        c(skew,
          skew_se,
          skew_2se,
          kurt,
          kurt_se,
          kurt_2se
        )
      } else {
        stop()
      }
    }, error = function(e){ rep(NA, 6) })

    names(out) <-
      c("skew", "skew_se", "skew_2se", "kurt", "kurt_se", "kurt_2se")
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
