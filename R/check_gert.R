gert_works <- function() {
  dir_name <- file.path(tempfile())
  if (dir.exists(dir_name))
    unlink(dir_name, recursive = TRUE, force = TRUE)
  dir.create(dir_name)
  on.exit(unlink(dir_name, recursive = TRUE), add = TRUE)
  pass <- !inherits(try({
    gert::git_init(dir_name)
  }, silent = TRUE)
  , "try-error")
  if (!pass)
    return(FALSE)
  pass <- !inherits(try({
    if (gert::user_is_configured(dir_name)) {
      gert::git_config_set("user.name", "Gert test", repo = dir_name)
      gert::git_config_set("user.email", "gert_test@gmail.com", repo = dir_name)
    }
    if (!gert::user_is_configured(dir_name))
      stop()
  }, silent = TRUE)
  , "try-error")
  if (!pass)
    return(FALSE)
  pass <- !inherits(try({
    gert::git_init()
  }, silent = TRUE)
  , "try-error")
  if (!pass)
    return(FALSE)
  pass <- !inherits(try({
    writeLines("test git", con = file.path(dir_name, "tmp.txt"))
    tmp <- gert::git_add(".", repo = dir_name)
    if (!isTRUE(tmp$staged))
      stop()
  }, silent = TRUE)
  , "try-error")
  if (!pass)
    return(FALSE)

  pass <-
    !inherits(try(gert::git_commit("First commit", repo = dir_name),
                  silent = TRUE)
              , "try-error")
  if (!pass)
    return(FALSE)
  return(TRUE)
}
