% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/github.R
\name{git_remote_create}
\alias{git_remote_create}
\alias{git_release_publish}
\title{Create a New 'GitHub' Repository}
\usage{
git_remote_create(name, private = TRUE)

git_release_publish(repo = ".", tag_name = NULL, release_name = NULL)
}
\arguments{
\item{name}{Name of the repository to be created.}

\item{private}{Whether or not the repository should be private, defaults to
\code{FALSE}.}

\item{repo}{The path to the 'Git' repository.}

\item{tag_name}{Optional character string to specify the tag name. By
default, this is set to \code{NULL} and \code{git_release_publish()} uses version
numbers starting with \verb{0.1.0} for both the \code{tag_name} and \code{release_name}
arguments. Override this behavior, for example, to increment the major
version number by specifying \verb{0.2.0}.}

\item{release_name}{Optional character string to specify the tag name. By
default, this is set to \code{NULL} and \code{git_release_publish()} uses version
numbers starting with \verb{0.1.0} for both the \code{tag_name} and \code{release_name}
arguments. Override this behavior, for example, to increment the major
version number by specifying \verb{0.2.0}.}
}
\value{
Invisibly returns a logical value,
indicating whether the function was successful or not.

No return value. This function is called for its side effects.
}
\description{
Given that a 'GitHub' user is configured, with the appropriate
permissions, this function creates a new repository on your account.

Given that a 'GitHub' user is configured, with the appropriate
permissions, this function pushes the current branch (if safe),
then publishes a 'GitHub' Release of the repository indicated by
\code{repo} to that user's account.
}
\examples{
\dontrun{
git_remote_create()
}
\dontrun{
git_release_publish()
}
}
