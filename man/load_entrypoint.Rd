% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_entrypoint.R
\name{load_entrypoint}
\alias{load_entrypoint}
\title{Load project entry points}
\usage{
load_entrypoint(worcs_directory = ".", verbose = TRUE, ...)
}
\arguments{
\item{worcs_directory}{Character, indicating the WORCS project directory to
which to save data. The default value \code{"."} points to the current
directory.}

\item{verbose}{Logical. Whether or not to print status messages to
the console. Default: TRUE}

\item{...}{Additional arguments passed to \code{\link[utils]{file.edit}}.}
}
\value{
No return value. This function is called for its side effects.
}
\description{
Loads the designated project entry point into the default
editor, using \code{\link[utils]{file.edit}}.
}
\examples{
\dontrun{
if(requireNamespace("withr", quietly = TRUE)){
  withr::with_tempdir({
    # Prepare worcs file and dummy entry point
    worcs:::write_worcsfile(".worcs", entry_point = "test.txt")
    writeLines("Hello world", con = file("test.txt", "w"))
    # Demonstrate load_entrypoint()
    load_entrypoint()
  })
}
}
}
