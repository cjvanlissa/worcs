# Notify the user when synthetic data are being used

This function prints a notification message when some or all of the data
used in a project are synthetic (see
[`closed_data`](https://cjvanlissa.github.io/worcs/reference/closed_data.md)
and
[`synthetic`](https://cjvanlissa.github.io/worcs/reference/synthetic.md)).
See details for important information.

## Usage

``` r
notify_synthetic(..., msg = NULL)
```

## Arguments

- ...:

  Objects of class `worcs_data`. The function will check if these are
  original or synthetic data.

- msg:

  Expression containing the message to print in case not all
  `worcs_data` are original. This message may refer to `is_synth`, a
  logical vector indicating which `worcs_data` objects are synthetic.

## Value

No return value. This function is called for its side effect of printing
a notification message.

## Details

The preferred way to use this function is to provide specific data
objects in the function call, using the `...` argument. If no such
objects are provided, `notify_synthetic` will scan the parent
environment for objects of class `worcs_data`.

This function is emphatically designed to be included in an 'R Markdown'
file, to dynamically generate a notification message when a third party
'Knits' such a document without having access to all original data.

## See also

closed_data synthetic add_synthetic

## Examples

``` r
df <- iris
class(df) <- c("worcs_data", class(df))
attr(df, "type") <- "synthetic"
result <- capture.output(notify_synthetic(df, msg = "synthetic"))
```
