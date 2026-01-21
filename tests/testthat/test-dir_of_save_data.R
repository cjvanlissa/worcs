test_that("data stored in correct dir", {
  the_path <- fs::file_temp(pattern = "savedat2")
  scoped_temporary_project(dir = the_path)

  file.create(".worcs")

  add_manuscript(
    worcs_directory = ".",
    manuscript = "github_document",
    remote_repo = "https"
  )
  data("iris")
  df1 <- iris[1:5, 1:4]
  closed_data(df1)
  withr::with_dir(file.path(the_path, "manuscript"), {
    df2 <- iris[10:15, 1:4]
    closed_data(df2)
  })

  f <- c("codebook_df1.csv", "codebook_df1.Rmd", "codebook_df2.csv", "codebook_df2.Rmd", "df1.csv", "df2.csv",
         "synthetic_df1.csv", "synthetic_df2.csv")
  if(isTRUE(pandoc_available("3"))){
    f <- c(f, "codebook_df1.html", "codebook_df1.md", "codebook_df2.html", "codebook_df2.md")
  }

  expect_true(all(sapply(f, file.exists)))
  expect_true(all(!sapply(file.path("manuscript", f), file.exists)))

  yml <- yaml::read_yaml(".worcs")
  expect_true(all(names(yml$data) == paste0("df", 1:2, ".csv")))
  expect_true(all(names(yml$checksums) %in% f))

  expect_true(tolower(yml$data$df1.csv$synthetic) %in% tolower(f))
  expect_true(tolower(yml$data$df2.csv$synthetic) %in% tolower(f))

  expect_true(tolower(yml$data$df1.csv$codebook) %in% tolower(f))
  expect_true(tolower(yml$data$df2.csv$codebook) %in% tolower(f))

})
