library(yaml)
library(digest)
test_that("save_expression and load_expression", {
  the_test <- "save_expression"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  worcs:::write_worcsfile(file.path(tempdir(), the_test, ".worcs"))
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)
  dat <- iris[1:5, ]
  open_data(dat,
            filename = "dat.dat",
            codebook = NULL,
            save_expression = write.table(data, file = filename, row.names = FALSE),
            load_expression = read.table(file = filename, header = TRUE, sep = " ", stringsAsFactors = TRUE))


  # test_that("loading open data works", {
  rm(dat)
  expect_error({load_data()}, NA)
  suppressWarnings(load_data())
  expect_warning({load_data()})

  df <- load_data(to_envir = FALSE)$dat

  # test_that("loaded data same as original", {
  expect_equivalent(iris[1:5, ], df)

  df <- rbind(df, df[40,])
  write.table(df, file = "dat.dat", row.names = FALSE)


  # test_that("loading open data fails when data changed", {
  expect_warning({load_data()})

  set.seed(555)
  dat <- iris
  closed_data(dat,
            filename = "dat.dat",
            codebook = NULL,
            save_expression = write.table(data, file = filename, row.names = FALSE),
            load_expression = read.table(file = filename, header = TRUE, sep = " ", stringsAsFactors = TRUE))

  checksums <- read_yaml(".worcs")
  tmp <- read.table(file = "synthetic_dat.dat", header = TRUE, sep = " ", stringsAsFactors = TRUE)

  # test_that("synthetic data similar", {
  expect_equivalent(dim(tmp), dim(dat))
  expect_equivalent(sapply(dat, class), sapply(tmp, class)) # read.table is read as character

  # test_that(".worcs contains checksum for synthetic_data.csv", {
  expect_true(!is.null(checksums$checksums[["synthetic_dat.dat"]]))
  expect_equivalent(checksums$checksums$synthetic_dat.dat, worcs:::cs_fun("synthetic_dat.dat"))

  # test_that("loading open data works", {
  rm(dat)
  expect_error({load_data()}, NA)

  file.remove("dat.dat")

  df <- load_data(to_envir = FALSE)$dat

  # test_that("loaded synthetic data same as original", {
  expect_equivalent(tmp, df)

  setwd(old_wd)
})
