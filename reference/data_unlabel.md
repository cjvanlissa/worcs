# Drop value labels

Coerces `factor` and `ordered` variables to class `integer`.

## Usage

``` r
data_unlabel(x, variables = names(x)[sapply(x, inherits, what = "factor")])
```

## Arguments

- x:

  A `data.frame`.

- variables:

  Column names of `x` to coerce to integer.

## Value

A `data.frame`.

## Examples

``` r
if (FALSE) { # \dontrun{
if(interactive()){
 df <- data.frame(x = factor(c("a", "b")))
 df <- data_unlabel(df)
 }
} # }
```
