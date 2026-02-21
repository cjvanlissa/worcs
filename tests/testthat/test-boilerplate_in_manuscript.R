test_that("boilerplate text is inserted", {
  worcs:::scoped_tempdir({
    if(requireNamespace("papaja", quietly = TRUE)){
      add_manuscript(manuscript = "apa6")
      lnz <- readLines("manuscript/manuscript.Rmd")
      expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
      expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
      file.remove("manuscript/manuscript.Rmd")
      unlink("manuscript", recursive = TRUE)
    }
    add_manuscript(manuscript = "github_document")
    lnz <- readLines("manuscript/manuscript.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
    file.remove("manuscript/manuscript.Rmd")
    unlink("manuscript", recursive = TRUE)
    add_manuscript(manuscript = "acm_article")
    lnz <- readLines("manuscript/manuscript.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
    file.remove("manuscript/manuscript.Rmd")
    unlink("manuscript", recursive = TRUE)
    add_manuscript(manuscript = "target_markdown")
    lnz <- readLines("_targets.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data(", lnz, fixed = TRUE)))
    file.remove("_targets.Rmd")
  })
})


test_that("boilerplate text is inserted", {
  worcs:::scoped_tempdir({
    add_manuscript(manuscript = "target_markdown")
    print(list.files())
    # lnz <- readLines("manuscript.Rmd")
    # print(lnz)
    #expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    #expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
  })
})
