% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/endpoint.R
\name{add_endpoint}
\alias{add_endpoint}
\title{Add endpoint to WORCS project}
\usage{
add_endpoint(filename = NULL, worcs_directory = ".", verbose = TRUE, ...)
}
\arguments{
\item{filename}{Character, indicating the file to be tracked as endpoint.
Default: NULL.}

\item{worcs_directory}{Character, indicating the WORCS project directory
to which to save data. The default value "." points to the current directory.
Default: '.'}

\item{verbose}{Logical. Whether or not to print status messages to the
console. Default: TRUE}

\item{...}{Additional arguments.}
}
\value{
No return value. This function is called for its side effects.
}
\description{
Add a specific endpoint to the WORCS project file. Endpoints are
files that are expected to be exactly reproducible (e.g., a manuscript,
figure, table, et cetera). Reproducibility is checked by ensuring the
endpoint's checksum is unchanged.
}
\examples{
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "add_endpoint")
dir.create(test_dir)
setwd(test_dir)
file.create(".worcs")
writeLines("test", "test.txt")
add_endpoint("test.txt")
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
}
\seealso{
\code{\link[worcs]{snapshot_endpoints}}
\code{\link[worcs]{check_endpoints}}
}
