# Describe a dataset

Provide descriptive statistics for a dataset.

## Usage

``` r
descriptives(x, ...)
```

## Arguments

- x:

  An object for which a method exists.

- ...:

  Additional arguments.

## Value

A `data.frame` with descriptive statistics for `x`.

## Examples

``` r
descriptives(iris)
#>           name    type   n missing unique     mean median  mode mode_value
#> 1 Sepal.Length numeric 150       0     35 5.843333   5.80  5.80       <NA>
#> 2  Sepal.Width numeric 150       0     23 3.057333   3.00  3.00       <NA>
#> 3 Petal.Length numeric 150       0     43 3.758000   4.35  4.35       <NA>
#> 4  Petal.Width numeric 150       0     22 1.199333   1.30  1.30       <NA>
#> 5      Species  factor 150       0      4       NA     NA 50.00     setosa
#>          sd         v min max range       skew   skew_2se       kurt   kurt_2se
#> 1 0.8280661        NA 4.3 7.9   3.6  0.3086407  0.7792448 -0.6058125 -0.7696120
#> 2 0.4358663        NA 2.0 4.4   2.4  0.3126147  0.7892781  0.1387047  0.1762076
#> 3 1.7652982        NA 1.0 6.9   5.9 -0.2694109 -0.6801988 -1.4168574 -1.7999470
#> 4 0.7622377        NA 0.1 2.5   2.4 -0.1009166 -0.2547904 -1.3581792 -1.7254034
#> 5        NA 0.6666667  NA  NA    NA         NA         NA         NA         NA
```
