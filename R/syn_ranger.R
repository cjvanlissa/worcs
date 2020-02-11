#' @title Generating synthetic data sets using ranger
#' @description This function is for internal use only.
#' Generates synthetic version(s) of a data set using the fast
#' implementation of random forests in \code{\link[ranger]{ranger}}.
#' @param y Vector of the outcome variable.
#' @param x Matrix of x variables.
#' @param xp Matrix of x variables for prediction.
#' @param smoothing Logical. Whether of not to smooth predictions.
#' @param proper Whether or not to bootstrap the data, Default: FALSE
#' @param ... Additional arguments passed to and from functions.
#' @return List with predictions and fit model.
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname syn.ranger
#' @importFrom ranger ranger
#' @keywords internal
#' @export
syn.ranger <- function(y, x, xp, smoothing, proper = FALSE, ...)
{
  dots <- list(...)
  dots[c("formula", "data")] <- NULL
  if("min.node.size" %in% names(dots)){
    dots[["min.node.size"]] <- max(1, dots[["min.node.size"]])  # safety
  }

  if (proper == TRUE) {
    s <- sample(length(y), replace = TRUE)
    y <- y[s]
    x <- x[s, , drop = FALSE]
  }

  for (i in which(sapply(x,class) != sapply(xp,class))){
    do.call(paste0("as.", class(x[,i])[1]), unname(xp[i])) # This is much faster than eval(parse())
  }

  if (is.factor(y)) {
    obslevels <- levels(y)
    y <- droplevels(y)
  }

  # fit a random forest
  Args <- c(list(
    formula = y ~ .,
    data = cbind.data.frame(y,x)
  ), dots)
  rf.fit <- do.call(ranger, Args)
  nodessyn <- predict(rf.fit, data = xp, type = "terminalNodes")$predictions
  nodesobs <- predict(rf.fit, data = x, type = "terminalNodes")$predictions
  ntree <- rf.fit$num.trees
  ndonors <- vector("list", nrow(xp))
  n0      <- vector("list", ntree)
  for (j in 1:nrow(xp)) {
    for (i in 1:ntree) {
      n0[[i]] <- y[nodesobs[,i] == nodessyn[j,i]]
    }
    empty <- sapply(n0, length)
    ndonors[[j]] <- unlist(n0[empty != 0])
  }

  yhat <- sapply(ndonors, sample, size = 1)

  if (is.factor(y)) yhat <- factor(yhat, levels = obslevels)
  if (!is.factor(y) & smoothing == "density") yhat <- syn.smooth(yhat,y)

  return(list(res = yhat, fit = rf.fit))  # "rf"
}
