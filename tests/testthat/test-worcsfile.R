library(yaml)

Args <- list(
  arg1 = "val1", arg2 = list(arg2.1 = "val2.1", arg2.2 = "val2.2"), arg3 = list(arg3.1 = "val3.1", arg3.2 = "val3.2"), arg4 = "hoi"
)
arg_list <- c(list(filename = "test.yaml"), Args, list(modify = FALSE))
do.call(worcs:::write_worcsfile, arg_list)

result <- read_yaml("test.yaml")

test_that("yaml read correctly", {
  expect_true(all(unlist(Args) == unlist(result)))
})

worcs:::write_worcsfile("test.yaml", arg4 = "replaced", modify = TRUE)
result <- read_yaml("test.yaml")
modified_args <- Args
modified_args$arg4 <- "replaced"

test_that("can replace one yaml key/value", {
  expect_true(all(unlist(modified_args) == unlist(result)))
})

worcs:::write_worcsfile("test.yaml", arg3 = list(arg3.1 = "replaced3.1"), modify = TRUE)
result <- read_yaml("test.yaml")
modified_args$arg3$arg3.1 <- "replaced3.1"

test_that("can replace one nested yaml key/value", {
  expect_true(all(unlist(modified_args) == unlist(result)))
})

worcs:::write_worcsfile("test.yaml", arg3 = list(arg3.new = "anewvalue"), modify = TRUE)
result <- read_yaml("test.yaml")
modified_args$arg3$arg3.new <- "anewvalue"


test_that("can append one nested yaml key/value", {
  expect_true(all(unlist(modified_args) == unlist(result)))
})
