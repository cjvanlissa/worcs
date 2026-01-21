scoped_tempdir <- function (code){

  tmp <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  old <- setwd(dir = new)
  on.exit(setwd(old))
  force(code)
}
