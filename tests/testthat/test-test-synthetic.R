if (requireNamespace("missRanger", quietly = TRUE)) {

library(missRanger)
test_that("Argument missingness_expression works", {
  iris_missings <- iris
  for(i in 1:10){
    iris_missings[sample.int(nrow(iris_missings), 1, replace = TRUE),
                  sample.int(ncol(iris_missings), 1, replace = TRUE)] <- NA
  }
  iris_miss_syn <- synthetic(iris_missings, missingness_expression = missRanger(data = data))
  expect_true(anyNA(iris_miss_syn))
})

}
