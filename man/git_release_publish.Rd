% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/github.R
\name{git_release_publish}
\alias{git_release_publish}
\title{Publish a Release on 'GitHub'}
\usage{
git_release_publish(repo = ".", tag_name = NULL, release_name = NULL)
}
\arguments{
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
No return value. This function is called for its side effects.
}
\description{
Given that a 'GitHub' user is configured, with the appropriate
permissions, this function pushes the current branch (if safe),
then publishes a 'GitHub' Release of the repository indicated by
\code{repo} to that user's account.
}
\examples{
\dontrun{
git_release_publish()
}
}
