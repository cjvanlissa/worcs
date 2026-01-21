# Using Custom Synthetic Data

``` r
library(worcs)
library(lavaan)
```

Oftentimes, it is not possible to share original research data publicly,
for example, due to privacy constraints. As explained in the `worcs`
paper, in such cases, it is advantageous to share a synthetic dataset
instead, so that the code can still be vetted, debugged, and adapted by
others. By default, the function
[`closed_data()`](https://cjvanlissa.github.io/worcs/reference/closed_data.md)
generates a synthetic dataset using the function
[`synthetic()`](https://cjvanlissa.github.io/worcs/reference/synthetic.md);
a rudimentary random forest-based algorithm. However, sometimes this
default option falls short. In such cases, it is possible to fully
customize synthetic dataset generation. This vignette discusses some of
the options.

## Generating Data from a Structural Equation Model

Structural equation models may have problems converging when estimated
on synthetic datasets. To avoid this problem, synthetic data can be
generated directly from the SEM model. Generating data from an SEM model
will often result in a synthetic dataset that will closely reproduce the
model parameters estimated on the original dataset.

### Illustrating the Problem

For this example, we will use the `PoliticalDemocracy` data included
with the `lavaan` package. Imagine that we collected these data, and are
not allowed to share them. In an existing `worcs` project, we could then
store them using the command:

``` r
library(lavaan)
library(tidySEM)
set.seed(4)
dat <- PoliticalDemocracy
closed_data(dat)
```

Now, we estimate our SEM-model, based on the example in the `lavaan`
documentation:

``` r
load_data()
model <- '
ind60 =~ x1 + x2 + x3
dem60 =~ y1 + a*y2 + b*y3 + c*y4
dem65 =~ y5 + a*y6 + b*y7 + c*y8

# regressions
dem60 ~ ind60
dem65 ~ ind60 + dem60

# residual correlations
y1 ~~ y5
y2 ~~ y4 + y6
y3 ~~ y7
y4 ~~ y8
y6 ~~ y8'

fit <- lavaan::sem(model, data = dat)
tidySEM::table_results(fit)
```

    #>              label est_sig   se pval       confint
    #> 1      ind60.BY.x1    1.00 0.00 <NA>  [1.00, 1.00]
    #> 2      ind60.BY.x2 2.18*** 0.14 0.00  [1.91, 2.45]
    #> 3      ind60.BY.x3 1.82*** 0.15 0.00  [1.52, 2.12]
    #> 4      dem60.BY.y1    1.00 0.00 <NA>  [1.00, 1.00]
    #> 5      dem60.BY.y2 1.19*** 0.14 0.00  [0.92, 1.46]
    #> 6      dem60.BY.y3 1.17*** 0.12 0.00  [0.94, 1.41]
    #> 7      dem60.BY.y4 1.25*** 0.12 0.00  [1.02, 1.48]
    #> 8      dem65.BY.y5    1.00 0.00 <NA>  [1.00, 1.00]
    #> 9      dem65.BY.y6 1.19*** 0.14 0.00  [0.92, 1.46]
    #> 10     dem65.BY.y7 1.17*** 0.12 0.00  [0.94, 1.41]
    #> 11     dem65.BY.y8 1.25*** 0.12 0.00  [1.02, 1.48]
    #> 12  dem60.ON.ind60 1.47*** 0.39 0.00  [0.70, 2.24]
    #> 13  dem65.ON.ind60  0.60** 0.23 0.01  [0.16, 1.04]
    #> 14  dem65.ON.dem60 0.87*** 0.07 0.00  [0.72, 1.01]
    #> 15      y1.WITH.y5    0.58 0.36 0.10 [-0.11, 1.28]
    #> 16      y2.WITH.y4   1.44* 0.69 0.04  [0.09, 2.79]
    #> 17      y2.WITH.y6  2.18** 0.74 0.00  [0.74, 3.63]
    #> 18      y3.WITH.y7    0.71 0.61 0.24 [-0.49, 1.91]
    #> 19      y4.WITH.y8    0.36 0.44 0.41 [-0.51, 1.23]
    #> 20      y6.WITH.y8   1.37* 0.58 0.02  [0.24, 2.50]
    #> 21    Variances.x1 0.08*** 0.02 0.00  [0.04, 0.12]
    #> 22    Variances.x2    0.12 0.07 0.08 [-0.02, 0.26]
    #> 23    Variances.x3 0.47*** 0.09 0.00  [0.29, 0.64]
    #> 24    Variances.y1 1.85*** 0.43 0.00  [1.01, 2.70]
    #> 25    Variances.y2 7.58*** 1.37 0.00 [4.90, 10.26]
    #> 26    Variances.y3 4.96*** 0.96 0.00  [3.08, 6.83]
    #> 27    Variances.y4 3.22*** 0.72 0.00  [1.81, 4.64]
    #> 28    Variances.y5 2.31*** 0.48 0.00  [1.37, 3.25]
    #> 29    Variances.y6 4.97*** 0.92 0.00  [3.16, 6.77]
    #> 30    Variances.y7 3.56*** 0.71 0.00  [2.17, 4.95]
    #> 31    Variances.y8 3.31*** 0.70 0.00  [1.93, 4.69]
    #> 32 Variances.ind60 0.45*** 0.09 0.00  [0.28, 0.62]
    #> 33 Variances.dem60 3.88*** 0.87 0.00  [2.18, 5.57]
    #> 34 Variances.dem65    0.16 0.23 0.47 [-0.28, 0.61]

This should work fine. But what if someone tries to reproduce our
analysis? They would not have access to the original data, only the
synthetic dataset. To simulate their experience reproducing the
analysis, we can load the synthetic dataset and try to run our model:

``` r
dat2 <- read.csv("synthetic_dat.csv", stringsAsFactors = FALSE)
fit2 <- lavaan::sem(model, data = dat2)
```

    #> Warning: lavaan->lav_object_post_check():  
    #>    some estimated lv variances are negative
    #> Warning: lavaan->lav_object_post_check():  
    #>    the covariance matrix of the residuals of the observed variables (theta) 
    #>    is not positive definite ; use lavInspect(fit, "theta") to investigate.

This should result in several warnings, about negative latent variable
variances (an impossibility) and a warning that the observed covariance
matrix of the residuals is not positive definite. In other words: the
model cannot be fit to the synthetic data, because the structure in the
data is not adequately reproduced by the default algorithm of
[`synthetic()`](https://cjvanlissa.github.io/worcs/reference/synthetic.md).

### Adding a Custom Dataset

A dataset generated *from the model* will be much better able to
reproduce that model. So, let’s use this SEM model to generate a
synthetic dataset:

``` r
set.seed(33)
dat_synthetic <- lavaan::simulateData(model = lavaan::partable(fit))
```

Note that the function
[`simulateData()`](https://rdrr.io/pkg/lavaan/man/simulateData.html)
accepts a parameter table as its argument, which must first be extracted
from the fitted model object using
[`partable()`](https://rdrr.io/pkg/lavaan/man/parTable.html).

To add this custom synthetic dataset to our original dataset, use the
function below. Note that `original_name` should reference the *file
name* of the data the synthetic dataset should be associated with, not
the name of the R-object. We started with an R-object called `dat`,
which we saved to a file called `dat.csv` using the function
[`closed_data()`](https://cjvanlissa.github.io/worcs/reference/closed_data.md).

``` r
add_synthetic(dat_synthetic, original_name = "dat.csv")
```

    #> ℹ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
    #> ✔ Storing synthetic data in "fn_write_synth_rel" and updating the checksum in "…
    #> 

If we now remove the original data, and call
[`load_data()`](https://cjvanlissa.github.io/worcs/reference/load_data.md)
again, we can verify that the synthetic dataset is loaded, and we can
see that it’s possible to reproduce the analysis - if not the exact
results - with it:

``` r
file.remove("dat.csv")
load_data()
fit2 <- lavaan::sem(model, data = dat)
tidySEM::table_results(fit2)
```

    #> [1] TRUE
    #>              label est_sig   se pval      confint
    #> 1      ind60.BY.x1    1.00 0.00 <NA> [1.00, 1.00]
    #> 2      ind60.BY.x2 2.20*** 0.05 0.00 [2.10, 2.31]
    #> 3      ind60.BY.x3 1.86*** 0.06 0.00 [1.74, 1.97]
    #> 4      dem60.BY.y1    1.00 0.00 <NA> [1.00, 1.00]
    #> 5      dem60.BY.y2 1.16*** 0.05 0.00 [1.06, 1.26]
    #> 6      dem60.BY.y3 1.19*** 0.04 0.00 [1.10, 1.27]
    #> 7      dem60.BY.y4 1.20*** 0.04 0.00 [1.12, 1.28]
    #> 8      dem65.BY.y5    1.00 0.00 <NA> [1.00, 1.00]
    #> 9      dem65.BY.y6 1.16*** 0.05 0.00 [1.06, 1.26]
    #> 10     dem65.BY.y7 1.19*** 0.04 0.00 [1.10, 1.27]
    #> 11     dem65.BY.y8 1.20*** 0.04 0.00 [1.12, 1.28]
    #> 12  dem60.ON.ind60 1.66*** 0.16 0.00 [1.35, 1.97]
    #> 13  dem65.ON.ind60 0.80*** 0.09 0.00 [0.62, 0.98]
    #> 14  dem65.ON.dem60 0.82*** 0.03 0.00 [0.77, 0.88]
    #> 15      y1.WITH.y5 0.64*** 0.13 0.00 [0.39, 0.90]
    #> 16      y2.WITH.y4 0.79*** 0.24 0.00 [0.33, 1.25]
    #> 17      y2.WITH.y6 2.67*** 0.30 0.00 [2.08, 3.25]
    #> 18      y3.WITH.y7   0.54* 0.22 0.01 [0.11, 0.97]
    #> 19      y4.WITH.y8   0.39* 0.17 0.02 [0.06, 0.71]
    #> 20      y6.WITH.y8 1.48*** 0.21 0.00 [1.06, 1.90]
    #> 21    Variances.x1 0.07*** 0.01 0.00 [0.06, 0.09]
    #> 22    Variances.x2 0.12*** 0.03 0.00 [0.07, 0.17]
    #> 23    Variances.x3 0.46*** 0.03 0.00 [0.39, 0.53]
    #> 24    Variances.y1 1.79*** 0.16 0.00 [1.47, 2.11]
    #> 25    Variances.y2 7.65*** 0.53 0.00 [6.60, 8.69]
    #> 26    Variances.y3 4.24*** 0.33 0.00 [3.60, 4.89]
    #> 27    Variances.y4 2.80*** 0.25 0.00 [2.31, 3.28]
    #> 28    Variances.y5 2.05*** 0.17 0.00 [1.72, 2.38]
    #> 29    Variances.y6 4.87*** 0.34 0.00 [4.20, 5.54]
    #> 30    Variances.y7 3.43*** 0.27 0.00 [2.91, 3.96]
    #> 31    Variances.y8 3.48*** 0.27 0.00 [2.94, 4.02]
    #> 32 Variances.ind60 0.42*** 0.03 0.00 [0.36, 0.48]
    #> 33 Variances.dem60 4.01*** 0.34 0.00 [3.34, 4.67]
    #> 34 Variances.dem65  0.26** 0.08 0.00 [0.09, 0.43]
