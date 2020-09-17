library(yaml)
library(digest)
# the_test <- "loaddata1"
# old_wd <- getwd()
# dir.create(file.path(tempdir(), the_test))
# setwd(file.path(tempdir(), the_test))
worcs:::write_worcsfile(".worcs")
open_data(iris[1:5, ], filename = "iris.csv", codebook = "codebook_iris.Rmd")
checksums <- read_yaml(".worcs")

test_that(".worcs contains correct checksum", {
  expect_equivalent(checksums$checksums$iris.csv, digest("iris.csv", file = TRUE))
})

test_that("loading open data works", {
  expect_error({load_data()}, NA)
  load_data()
  expect_warning({load_data()})
})

df <- load_data(to_envir = FALSE)$iris

test_that("loaded data same as original", {
  expect_equivalent(iris[1:5, ], df)
})

df <- rbind(df, df[40,])
write.csv(df, "iris.csv", row.names = FALSE)

test_that("loading open data fails when data changed", {
  expect_error({load_data()})
})

set.seed(555)
closed_data(iris, codebook = NULL)
checksums <- read_yaml(".worcs")
tmp <- read.csv("synthetic_iris.csv", stringsAsFactors = TRUE)

test_that("synthetic data similar", {
  expect_equivalent(dim(tmp), dim(iris))
  expect_equivalent(sapply(iris, class), sapply(tmp, class))
})

test_that(".worcs contains checksum for synthetic_data.csv", {
  expect_true(!is.null(checksums$checksums[["synthetic_iris.csv"]]))
  expect_equivalent(checksums$checksums$synthetic_iris.csv, digest("synthetic_iris.csv", file = TRUE))
})

test_that("loading open data works", {
  expect_error({load_data()}, NA)
})

file.remove("iris.csv")

df <- load_data(to_envir = FALSE)$iris

test_that("loaded synthetic data same as original", {
  expect_equivalent(tmp, df)
})

rm("iris")
test_that("loading open data succeeds when loading from a subdirectory", {
  skip_on_travis()
  old_wd <- getwd()
  dir.create(file.path(old_wd, "manuscript"))
  setwd(file.path(old_wd, "manuscript"))
  expect_error({load_data()}, NA)
  setwd(old_wd)
})


# setwd(old_wd)
# unlink(file.path(tempdir(), the_test))
