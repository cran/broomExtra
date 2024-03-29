% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grouped_generics.R
\name{grouped_glance}
\alias{grouped_glance}
\title{Grouped model summary}
\usage{
grouped_glance(data, grouping.vars, ..f, ...)
}
\arguments{
\item{data}{Dataframe (or tibble) from which variables are to be taken.}

\item{grouping.vars}{Grouping variables.}

\item{..f}{A function, or function name as a string.}

\item{...}{<\link[rlang:dyn-dots]{dynamic}> Arguments for \code{.fn}.}
}
\description{
Model summary output from grouped analysis of any function that
has \code{data} argument in its function call.
}
\examples{
set.seed(123)
library(dplyr)

# linear mixed effects model
grouped_glance(
  data = mutate(MASS::Aids2, interval = death - diag),
  grouping.vars = sex,
  ..f = lme4::lmer,
  formula = interval ~ age + (1 | status),
  control = lme4::lmerControl(optimizer = "bobyqa")
)
}
\seealso{
\code{\link{glance}}
}
