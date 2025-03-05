#' @title Generate synthetic data
#' @description Generates a synthetic version of a \code{data.frame}, with
#' similar characteristics to the original. See Details for the algorithm used.
#' @param data A data.frame of which to make a synthetic version.
#' @param model_expression An R-expression to estimate a model. Defaults to
#' \code{ranger(x = x, y = y)}, which uses the fast implementation of random
#' forests in \code{\link[ranger]{ranger}}. The expression is evaluated in an
#' environment containing objects \code{x} and \code{y}, where \code{x} is a
#' \code{data.frame} with the predictor variables, and \code{y} is a
#' \code{vector} of outcome values (see Details).
#' @param predict_expression An R-expression to generate predicted values based
#' on the model estimated by \code{model_expression}. Defaults to
#' \code{predict(model, data = xsynth)$predictions}. This expression must return
#' a vector of predicted values. The expression is evaluated in an
#' environment containing objects \code{model} and \code{xsynth}, where
#' \code{model} is the model estimated by \code{model_expression}, and
#' \code{xsynth} is the \code{data.frame} of synthetic data used to predict the
#' next column (see Details).
#' @param missingness_expression Optional. An R-expression to impute missing
#' values. Defaults to \code{NULL}, which means listwise deletion is used. The
#' expression is evaluated in an environment containing the object \code{data},
#' as specified in the call to \code{synthetic}. It must return a
#' \code{data.frame} with the same dimensions and column names as the original
#' data. For example, use \code{missingness_expression =
#' missRanger::missRanger(data = data)} for a fast implementation of the
#' excellent 'missForest' single imputation technique.
#' @param verbose Logical, Default: TRUE. Whether to show a progress bar while
#' running the algorithm and provide informative messages.
#' @return A \code{data.frame} with synthetic data, based on \code{data}.
#' @details Based on the work by Nowok, Raab, and Dibben (2016),
#' this function uses a simple algorithm to generate a synthetic
#' dataset with similar characteristics to the original. The algorithm is as
#' follows:
#' \enumerate{
#' \item Let x be the original data.frame, with columns 1:j
#' \item Let xsynth be a synthetic data.frame, with columns 1:j
#' \item Column 1 of xsynth is a bootstrapped version of column 1 of x
#' \item Using \code{model_expression}, a predictive model is built for column
#' c, for c along 2:j, with c predicted from columns 1:(c-1) of the original
#' data.
#' \item Using \code{predict_expression}, columns 1:(c-1) of the synthetic data
#' are used to predict synthetic values for column c.
#' }
#' Variables are thus imputed in order of occurrence in the \code{data.frame}.
#' To impute in a different order, reorder the data.
#'
#' Note that, for data synthesis to work properly, it is essential that the
#' \code{class} of variables is defined correctly. The default algorithm
#' \code{\link[ranger]{ranger}} supports numeric, integer, and factor types.
#' Other types of variables should be converted to one of these types, or users
#' can use a custom \code{model_expression} and \code{predict_expressio}
#' when calling \code{synthetic}.
#'
#'
#' Note that for data synthesis to work properly, it is essential that the
#' \code{class} of variables is defined correctly. The default algorithm
#' \code{\link[ranger]{ranger}} supports numeric, integer, factor, and logical
#' data. Other types of variables should be converted to one of these types.
#'
#' Users can provide use a custom \code{model_expression} and
#' \code{predict_expression} to use a different algorithm when calling
#' \code{synthetic}.
#'
#' As demonstrated in the example, users could call \code{lm} as a
#' \code{model_expression} to use
#' linear regression, which preserves linear marginal relationships but can give
#' rise to values out of range of the original data.
#' Or users could call \code{sample} as a \code{predict_expression} to bootstrap
#' each variable, a very quick solution that maintains univariate distributions
#' but loses all marginal relationships. These examples are not exhaustive, and
#' users can even create custom functions.
#' @examples
#' \dontrun{
#' # Example using the iris dataset and default ranger algorithm
#' iris_syn <- synthetic(iris)
#'
#' # Example using lm as prediction algorithm (only works for numeric variables)
#' # note that, within the model_expression, a new data.frame is created because
#' # lm() requires a separate data argument:
#' dat <- iris[, 1:4]
#' result <- synthetic(dat,
#'           model_expression = lm(.outcome ~ .,
#'                                 data = data.frame(.outcome = y,
#'                                 xsynth)),
#'           predict_expression = predict(model, newdata = xsynth), verbose = FALSE)
#' }
#' # Example using bootstrapping:
#' result <- synthetic(iris,
#'           model_expression = NULL,
#'           predict_expression = sample(y, size = length(y), replace = TRUE), verbose = FALSE)
#' \dontrun{
#' # Example with missing data, no imputation
#' iris_missings <- iris
#' for(i in 1:10){
#'   iris_missings[sample.int(nrow(iris_missings), 1, replace = TRUE),
#'                 sample.int(ncol(iris_missings), 1, replace = TRUE)] <- NA
#' }
#' iris_miss_syn <- synthetic(iris_missings)
#'
#' # Example with missing data, imputation by median/mode substitution
#' # First, define a simple function for median/mode substitution:
#' imp_fun <- function(x){
#'   if(is.data.frame(x)){
#'     return(data.frame(sapply(x, imp_fun)))
#'   } else {
#'     out <- x
#'     if(inherits(x, "numeric")){
#'       out[is.na(out)] <- median(x[!is.na(out)])
#'     } else {
#'       out[is.na(out)] <- names(sort(table(out), decreasing = TRUE))[1]
#'     }
#'     out
#'   }
#' }
#'
#' # Then, call synthetic() with this function as missingness_expression:
#' iris_miss_syn <- synthetic(iris_missings,
#'                            missingness_expression = imp_fun(data))
#' }
#' @references Nowok, B., Raab, G.M and Dibben, C. (2016).
#' synthpop: Bespoke creation of synthetic data in R. Journal of Statistical
#' Software, 74(11), 1-26. \doi{10.18637/jss.v074.i11}.
#' @rdname synthetic
#' @export
synthetic <- function(data,
                      model_expression = ranger(x = x, y = y),
                      predict_expression = predict(model, data = xsynth)$predictions,
                      missingness_expression = NULL,
                      verbose = TRUE){
  UseMethod("synthetic", data)
}

if(getRversion() >= "2.15.1") utils::globalVariables(c("x", "y", "model", "xsynth"))

#' @method synthetic matrix
#' @export
synthetic.matrix <- function(data,
                             model_expression = ranger(x = x, y = y),
                             predict_expression = predict(model, data = xsynth)$predictions,
                             missingness_expression = NULL,
                             verbose = TRUE){
  cl <- match.call(expand.dots = FALSE)
  cl[["data"]] <- data.frame(data)
  cl[[1L]] <- quote(synthetic)
  eval(cl, parent.frame())
}


#' @importFrom stats na.omit complete.cases predict
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom ranger ranger
#' @method synthetic data.frame
#' @export
synthetic.data.frame <- function(data,
                                 model_expression = ranger(x = x, y = y),
                                 predict_expression = predict(model, data = xsynth)$predictions,
                                 missingness_expression = NULL,
                                 verbose = TRUE){
  # Capture expressions
  model_expression <- substitute(model_expression) # model_expression <- quote(ranger(x = x, y = y))
  predict_expression <- substitute(predict_expression) # predict_expression <- quote(predict(model, data = xsynth)$predictions)
  missingness_expression <- substitute(missingness_expression)
  # Check if input is correct
  # if(!is.null(model_expression)){
  #   me <- deparse(model_expression)
  #   if(!(grepl("\\bx\\b", me) & grepl("\\by\\b", me))){
  #     #stop("Argument 'model_expression' must use the arguments 'x' and 'y' to refer to the predictor variables and outcome variable, respectively.")
  #   }
  # }
  pe <- deparse(predict_expression)
  # if(!((grepl("\\bmodel\\b", pe) & grepl("\\bxsynth\\b", pe)) | (is.null(model_expression) & grepl("\\by\\b", pe)))){
  #   stop("Argument 'predict_expression' must use the arguments 'model' and 'xsynth' to refer to the model generated by 'model_expression' and the synthetic predictor data.frame, respectively.")
  # }

  # Check if data is in expected format
  if(!is.data.frame(data)) data <- data.frame(data)

  # Analyze missing values
  miss_props <- analyze_missing(data)

  if(any(miss_props > 0)){
    if(is.null(missingness_expression)){
      if(verbose) col_message("Argument 'data' has missing values, but no 'missingness_expression' is specified. Listwise deletion is used.", success = FALSE)
    } else {
      data <- eval(missingness_expression)
    }
  }

  # Number of obs
  nobs <- nrow(data)
  # Analyze data types
  coltypes <- lapply(data, class)

  # Bootstrap first column
  x <- na.omit(data[, 1, drop = FALSE])
  assign(names(data)[1], x[sample.int(nrow(x), nobs, replace = TRUE), , drop = FALSE])
  xsynth <- data.frame(mget(names(data)[1]))

  # For all other columns, evaluate model_expression on columns up until
  # that one, then predict it based on existing synthetic data and add
  # column to synthetic data
  if(ncol(data) > 1){
    if(verbose){
      pb <- txtProgressBar(min = 0, max = ncol(data), style = 3)
      setTxtProgressBar(pb, 1)
    }
    for(this_col in 2:ncol(data)){
      # Listwise deletion
      complete_cases <- complete.cases(data[1:this_col])
      # Prepare x and y
      x <- data[1:(this_col-1)][complete_cases, , drop = FALSE]
      y <- data[[this_col]][complete_cases]
      # Evaluate model
      if(!is.null(model_expression)){
        model <- eval(model_expression)
      }
      # Obtain predictions
      pred <- eval(predict_expression)
      # Add column to xsynth
      xsynth[[names(data)[this_col]]] <- pred
      if(verbose) setTxtProgressBar(pb, this_col)
    }
    if(verbose) close(pb)
  }

  # Check if variable classes are maintained
  for(thisvar in 1:ncol(data)){
    #thisvar=6
    if(!all(class(xsynth[[thisvar]]) == coltypes[[thisvar]])){
      msg <- paste0("Synthetic variable '", names(data)[thisvar], "' did not have identical classes to its original counterpart.")
      # Try to convert to correct class
      convert_func <- paste0("as.", coltypes[[thisvar]])
      convert_func <- convert_func[sapply(convert_func, exists)]
      if(length(convert_func) > 0) convert_func <- convert_func[1]
      newvar <- tryCatch({
        do.call(convert_func, list(xsynth[[thisvar]]))
      }, error = function(e){NULL})
      if(!is.null(newvar)){
        col_message(msg, " Attempted to convert to its original type. Check the input types of your variables, and check whether the data are synthesized correctly.", success = TRUE, verbose = verbose)
        xsynth[[thisvar]] <- newvar
      } else {
        col_message(msg, " Failed to convert to its original type. Check the input types of your variables, and check whether the data are synthesized correctly.", success = FALSE)
      }
    }
  }

  # Restore missing values
  if(any(miss_props > 0)){
    xsynth <- insert_missing(xsynth, miss_props)
  }
  rownames(xsynth) <- NULL
  return(xsynth)
}

analyze_missing <- function(x){
  miss <- colSums(is.na(x))
  miss/nrow(x)
}

#' @importFrom stats rbinom
insert_missing <- function(x, props){
  x[1:ncol(x)] <- mapply(function(col, prop){
    col[as.logical(rbinom(length(col), 1, prop))] <- NA
    col
  }, col = x[1:ncol(x)], prop = props)
  x
}
