% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logger.R
\name{setMsgComposer}
\alias{setMsgComposer}
\title{Sets message composer for logger.}
\usage{
setMsgComposer(composer_f, container = "")
}
\arguments{
\item{composer_f}{message composer function (type: function(msg, ...))}

\item{container}{name of logger to reset message composer for (type: character)}
}
\description{
Message composer is used to compose log message out of formatting string and arguments.
It is function with signature \code{function(msg, ...)}. Formatting message is passed under msg
and formatting arguments are passed as \code{...}.
}
\details{
If message composer is not set default is in use (realized with \code{sprintf}). If message
composer is not set for sub-logger, parent's message composer will be used.
}
