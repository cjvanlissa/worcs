test_that("boilerplate text is inserted", {
  worcs:::scoped_tempdir({
    if(requireNamespace("papaja", quietly = TRUE)){
      add_manuscript(manuscript = "apa6")
      lnz <- readLines("manuscript/manuscript.Rmd")
      expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
      expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
      file.remove("manuscript/manuscript.Rmd")
    }
    add_manuscript(manuscript = "github_document")
    lnz <- readLines("manuscript/manuscript.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
    file.remove("manuscript/manuscript.Rmd")
    if(requireNamespace("rticles", quietly = TRUE)){
    add_manuscript(manuscript = "acm_article")
    lnz <- readLines("manuscript/manuscript.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data()", lnz, fixed = TRUE)))
    file.remove("manuscript/manuscript.Rmd")
    }
    if(requireNamespace("targets", quietly = TRUE) & requireNamespace("tarchetypes", quietly = TRUE)){
    add_manuscript(manuscript = "target_markdown")
    lnz <- readLines("_targets.Rmd")
    expect_true(any(grepl("Workflow for Open Reproducible Code in Science", lnz, fixed = TRUE)))
    expect_true(any(grepl("load_data(", lnz, fixed = TRUE)))
    expect_error(rmarkdown::render("_targets.Rmd", quiet = TRUE), NA)
    }
  })
})
