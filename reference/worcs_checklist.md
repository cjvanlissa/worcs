# WORCS checklist

This checklist can be used to see whether a project adheres to the
principles of open reproducible code in science, as set out in the WORCS
paper.

## Usage

``` r
data(worcs_checklist)
```

## Format

A data frame with 15 rows and 5 variables.

## Details

|                 |           |                                                                                                                                 |
|-----------------|-----------|---------------------------------------------------------------------------------------------------------------------------------|
| **category**    | `factor`  | Category of the checklist element.                                                                                              |
| **name**        | `factor`  | Name of the checklist element.                                                                                                  |
| **description** | `factor`  | What are the requirements to claim that this checklist element is met?                                                          |
| **importance**  | `factor`  | Whether the checklist element is essential to obtain a green 'open science' badge, or optional.                                 |
| **check**       | `logical` | Whether the criterion is checked automatically by [`worcs_badge`](https://cjvanlissa.github.io/worcs/reference/worcs_badge.md). |

## References

Van Lissa, C. J., Brandmaier, A. M., Brinkman, L., Lamprecht, A.,
Peikert, A., , Struiksma, M. E., & Vreede, B. (2021)
[doi:10.3233/DS-210031](https://doi.org/10.3233/DS-210031) .
