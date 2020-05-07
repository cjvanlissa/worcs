tmp <- descfun(iris)

test_that("descfun creates correct output", {
  expect_true(all(c("missing", "unique", "mean", "median", "mode", "mode_value",
    "sd", "V", "min", "max", "range", "skew", "skew_2se", "kurt",
    "kurt_2se") %in% names(tmp)))
  num_vars <- sapply(iris, class) == "numeric"
  num_cols <- c("missing", "unique", "mean", "median", "mode", "sd", "min", "max", "range", "skew", "skew_2se", "kurt", "kurt_2se")
  expect_true(all(!is.na(tmp[num_vars, num_cols])))

  fac_cols <- c("missing", "unique", "mode", "mode_value", "V")
  expect_true(all(!is.na(tmp[!num_vars, fac_cols])))

  expect_true(all(is.na(tmp[num_vars, c("mode_value", "V")])))
  expect_true(all(is.na(tmp[!num_vars, c("mean", "median", "sd", "min", "max", "range", "skew", "skew_2se", "kurt", "kurt_2se")])))
})
