test_that("data stored in correct dir", {
  the_test <- "savedat6"
  old_wd <- getwd()
  test_dir <- file.path(tempdir(), the_test)
  dir.create(test_dir)
  setwd(test_dir)
  file.create(file.path(tempdir(), the_test, ".worcs"))
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

  add_manuscript(
    worcs_directory = ".",
    manuscript = "github_document",
    remote_repo = "bla"
  )
  data("iris")
  df1 <- iris[1:5, 1:4]
  closed_data(df1)
  setwd(file.path(test_dir, "manuscript"))
  df2 <- iris[10:15, 1:4]
  closed_data(df2)
  setwd(test_dir)


  f <- c("codebook_df1.csv", "codebook_df1.html", "codebook_df1.md",
         "codebook_df1.Rmd", "codebook_df2.csv", "codebook_df2.html",
         "codebook_df2.md", "codebook_df2.Rmd", "df1.csv", "df2.csv",
         "synthetic_df1.csv", "synthetic_df2.csv")

  expect_true(all(sapply(f, file.exists)))
  expect_true(all(!sapply(file.path("manuscript", f), file.exists)))

  yml <- yaml::read_yaml(".worcs")
  expect_true(all(names(yml$data) == paste0("df", 1:2, ".csv")))
  expect_true(all(names(yml$checksums) %in% f))

  expect_true(yml$data$df1.csv$synthetic %in% f)
  expect_true(yml$data$df2.csv$synthetic %in% f)
  expect_true(yml$data$df1.csv$codebook %in% f)
  expect_true(yml$data$df2.csv$codebook %in% f)
  setwd(old_wd)
})
