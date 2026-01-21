# Calculate skew and kurtosis

Calculate skew and kurtosis, standard errors for both, and the estimates
divided by two times the standard error. If this latter quantity exceeds
an absolute value of 1, the skew/kurtosis is significant. With very
large sample sizes, significant skew/kurtosis is common.

## Usage

``` r
skew_kurtosis(x, verbose = FALSE, se = FALSE, ...)
```

## Arguments

- x:

  An object for which a method exists.

- verbose:

  Logical. Whether or not to print messages to the console, Default:
  FALSE

- se:

  Whether or not to return the standard errors, Default: FALSE

- ...:

  Additional arguments to pass to and from functions.

## Value

A `matrix` of skew and kurtosis statistics for `x`.

## Examples

``` r
skew_kurtosis(datasets::anscombe)
#>           skew   skew_2se       kurt   kurt_2se
#> x1  0.00000000  0.0000000 -1.5289256 -0.5975093
#> x2  0.00000000  0.0000000 -1.5289256 -0.5975093
#> x3  0.00000000  0.0000000 -1.5289256 -0.5975093
#> x4  2.46691100  1.8669273  4.5206612  1.7666896
#> y1 -0.04837355 -0.0366085 -1.1991228 -0.4686212
#> y2 -0.97869294 -0.7406626 -0.5143191 -0.2009976
#> y3  1.38012040  1.0444578  1.2400439  0.4846133
#> y4  1.12077386  0.8481876  0.6287512  0.2457181
```
