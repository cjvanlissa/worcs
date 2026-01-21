# Connect to Existing 'GitHub' Repository

Given that a 'GitHub' user is configured, with the appropriate
permissions, this function connects to an existing repository.

## Usage

``` r
git_remote_connect(repo, remote_repo)
```

## Arguments

- repo:

  a path to an existing repository, or a git_repository object as
  returned by git_open, git_init or git_clone.

- remote_repo:

  Character, indicating the name of a repository on your account.

## Value

Invisibly returns a list with the following elements:

- repo_url: Character, URL of the connected repository

- repo_exists: Logical

- prior_commits: Logical

## See also

[`gh_whoami`](https://gh.r-lib.org/reference/gh_whoami.html)
[`git_fetch`](https://docs.ropensci.org/gert/reference/git_fetch.html),
[`git_remote`](https://docs.ropensci.org/gert/reference/git_remote.html)

## Examples

``` r
if (FALSE) { # \dontrun{
git_remote_connect()
} # }
```
