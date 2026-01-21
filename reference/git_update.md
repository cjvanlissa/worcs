# Add, commit, and push changes.

This function is a wrapper for
[`git_add`](https://docs.ropensci.org/gert/reference/git_commit.html),
[`git_commit`](https://docs.ropensci.org/gert/reference/git_commit.html),
and
[`git_push`](https://docs.ropensci.org/gert/reference/git_fetch.html).
It adds all locally changed files to the staging area of the local 'Git'
repository, then commits these changes (with an optional) `message`, and
then pushes them to a remote repository. This is used for making a
"cloud backup" of local changes. Do not use this function when working
with privacy sensitive data, or any other file that should not be pushed
to a remote repository. The
[`git_add`](https://docs.ropensci.org/gert/reference/git_commit.html)
argument `force` is disabled by default, to avoid accidentally
committing and pushing a file that is listed in `.gitignore`.

## Usage

``` r
git_update(
  message = paste0("update ", Sys.time()),
  files = ".",
  repo = ".",
  author,
  committer,
  remote,
  refspec,
  password,
  ssh_key,
  mirror,
  force,
  verbose = TRUE
)
```

## Arguments

- message:

  a commit message

- files:

  vector of paths relative to the git root directory. Use "." to stage
  all changed files.

- repo:

  a path to an existing repository, or a git_repository object as
  returned by git_open, git_init or git_clone.

- author:

  A git_signature value, default is git_signature_default.

- committer:

  A git_signature value, default is same as author

- remote:

  name of a remote listed in git_remote_list()

- refspec:

  string with mapping between remote and local refs

- password:

  a string or a callback function to get passwords for authentication or
  password protected ssh keys. Defaults to askpass which checks
  getOption('askpass').

- ssh_key:

  path or object containing your ssh private key. By default we look for
  keys in ssh-agent and credentials::ssh_key_info.

- mirror:

  use the –mirror flag

- force:

  use the –force flag

- verbose:

  display some progress info while downloading

## Value

No return value. This function is called for its side effects.

## Examples

``` r
git_update()
```
