# Generate synthetic data

Generates a synthetic version of a `data.frame`, with similar
characteristics to the original. See Details for the algorithm used.

## Usage

``` r
synthetic(
  data,
  model_expression = ranger(x = x, y = y),
  predict_expression = predict(model, data = xsynth)$predictions,
  missingness_expression = NULL,
  verbose = TRUE
)
```

## Arguments

- data:

  A data.frame of which to make a synthetic version.

- model_expression:

  An R-expression to estimate a model. Defaults to
  `ranger(x = x, y = y)`, which uses the fast implementation of random
  forests in
  [`ranger`](http://imbs-hl.github.io/ranger/reference/ranger.md). The
  expression is evaluated in an environment containing objects `x` and
  `y`, where `x` is a `data.frame` with the predictor variables, and `y`
  is a `vector` of outcome values (see Details).

- predict_expression:

  An R-expression to generate predicted values based on the model
  estimated by `model_expression`. Defaults to
  `predict(model, data = xsynth)$predictions`. This expression must
  return a vector of predicted values. The expression is evaluated in an
  environment containing objects `model` and `xsynth`, where `model` is
  the model estimated by `model_expression`, and `xsynth` is the
  `data.frame` of synthetic data used to predict the next column (see
  Details).

- missingness_expression:

  Optional. An R-expression to impute missing values. Defaults to
  `NULL`, which means listwise deletion is used. The expression is
  evaluated in an environment containing the object `data`, as specified
  in the call to `synthetic`. It must return a `data.frame` with the
  same dimensions and column names as the original data. For example,
  use `missingness_expression = missRanger::missRanger(data = data)` for
  a fast implementation of the excellent 'missForest' single imputation
  technique.

- verbose:

  Logical, Default: TRUE. Whether to show a progress bar while running
  the algorithm and provide informative messages.

## Value

A `data.frame` with synthetic data, based on `data`.

## Details

Based on the work by Nowok, Raab, and Dibben (2016), this function uses
a simple algorithm to generate a synthetic dataset with similar
characteristics to the original. The algorithm is as follows:

1.  Let x be the original data.frame, with columns 1:j

2.  Let xsynth be a synthetic data.frame, with columns 1:j

3.  Column 1 of xsynth is a bootstrapped version of column 1 of x

4.  Using `model_expression`, a predictive model is built for column c,
    for c along 2:j, with c predicted from columns 1:(c-1) of the
    original data.

5.  Using `predict_expression`, columns 1:(c-1) of the synthetic data
    are used to predict synthetic values for column c.

Variables are thus imputed in order of occurrence in the `data.frame`.
To impute in a different order, reorder the data.

Note that, for data synthesis to work properly, it is essential that the
`class` of variables is defined correctly. The default algorithm
[`ranger`](http://imbs-hl.github.io/ranger/reference/ranger.md) supports
numeric, integer, and factor types. Other types of variables should be
converted to one of these types, or users can use a custom
`model_expression` and `predict_expressio` when calling `synthetic`.

Note that for data synthesis to work properly, it is essential that the
`class` of variables is defined correctly. The default algorithm
[`ranger`](http://imbs-hl.github.io/ranger/reference/ranger.md) supports
numeric, integer, factor, and logical data. Other types of variables
should be converted to one of these types.

Users can provide use a custom `model_expression` and
`predict_expression` to use a different algorithm when calling
`synthetic`.

As demonstrated in the example, users could call `lm` as a
`model_expression` to use linear regression, which preserves linear
marginal relationships but can give rise to values out of range of the
original data. Or users could call `sample` as a `predict_expression` to
bootstrap each variable, a very quick solution that maintains univariate
distributions but loses all marginal relationships. These examples are
not exhaustive, and users can even create custom functions.

## References

Nowok, B., Raab, G.M and Dibben, C. (2016). synthpop: Bespoke creation
of synthetic data in R. Journal of Statistical Software, 74(11), 1-26.
[doi:10.18637/jss.v074.i11](https://doi.org/10.18637/jss.v074.i11) .

## Examples

``` r
if (FALSE) { # \dontrun{
# Example using the iris dataset and default ranger algorithm
iris_syn <- synthetic(iris)

# Example using lm as prediction algorithm (only works for numeric variables)
# note that, within the model_expression, a new data.frame is created because
# lm() requires a separate data argument:
dat <- iris[, 1:4]
result <- synthetic(dat,
          model_expression = lm(.outcome ~ .,
                                data = data.frame(.outcome = y,
                                xsynth)),
          predict_expression = predict(model, newdata = xsynth), verbose = FALSE)
} # }
# Example using bootstrapping:
result <- synthetic(iris,
          model_expression = NULL,
          predict_expression = sample(y, size = length(y), replace = TRUE), verbose = FALSE)
if (FALSE) { # \dontrun{
# Example with missing data, no imputation
iris_missings <- iris
for(i in 1:10){
  iris_missings[sample.int(nrow(iris_missings), 1, replace = TRUE),
                sample.int(ncol(iris_missings), 1, replace = TRUE)] <- NA
}
iris_miss_syn <- synthetic(iris_missings)

# Example with missing data, imputation by median/mode substitution
# First, define a simple function for median/mode substitution:
imp_fun <- function(x){
  if(is.data.frame(x)){
    return(data.frame(sapply(x, imp_fun)))
  } else {
    out <- x
    if(inherits(x, "numeric")){
      out[is.na(out)] <- median(x[!is.na(out)])
    } else {
      out[is.na(out)] <- names(sort(table(out), decreasing = TRUE))[1]
    }
    out
  }
}

# Then, call synthetic() with this function as missingness_expression:
iris_miss_syn <- synthetic(iris_missings,
                           missingness_expression = imp_fun(data))
} # }
```
