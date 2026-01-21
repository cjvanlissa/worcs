scoped_tempdir <- function (code){

  new <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  dir.create(new)
  on.exit(unlink(new, recursive = TRUE), add = TRUE)
  old <- setwd(dir = new)
  on.exit(setwd(old))
  force(code)
}
