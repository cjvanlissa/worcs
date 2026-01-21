# Report formatted number

Report a number, rounded to a specific number of decimals (defaults to
two), using [`formatC`](https://rdrr.io/r/base/formatc.html). Intended
for 'R Markdown' reports.

## Usage

``` r
report(x, digits = 2, equals = TRUE)
```

## Arguments

- x:

  Numeric. Value to be reported

- digits:

  Integer. Number of digits to round to.

- equals:

  Logical. Whether to report an equals (or: smaller than) sign.

## Value

An atomic character vector.

## Author

Caspar J. van Lissa

## Examples

``` r
if(interactive()){
report(.0234)
}
```
