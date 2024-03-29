#' @name tidy_parameters
#' @title Tidy dataframes of model parameters using `{broom}` and `{easystats}`
#'
#' @description
#'
#' Computes parameters for regression models.
#'
#' @details The function will attempt to get these details first using
#'   [parameters::model_parameters()], and if this fails, then using
#'   [broom::tidy()].
#'
#' @inheritParams tidy
#' @param conf.int Indicating whether or not to include a confidence interval in
#'   the tidied output (defaults to `TRUE`).
#' @param ... Additional arguments that will be passed to
#'   [parameters::model_parameters()] or [broom::tidy()], whichever method
#'   works. Note that you should pay attention to different naming conventions
#'   across these packages. For example, the required confidence interval width
#'   is specified using `ci` argument in `parameters::model_parameters`, while
#'   using `conf.level` in `broom::tidy`.
#'
#' @return A data frame of indices related to the model's parameters.
#'
#' @examples
#' set.seed(123)
#' mod <- lm(mpg ~ wt + cyl, data = mtcars)
#' broomExtra::tidy_parameters(mod)
#' @import parameters
#'
#' @export

tidy_parameters <- function(x, conf.int = TRUE, ...) {
  # easystats family ---------------------------------------

  # check if `{easystats}` family has a tidy method for a given object
  m <- tryCatch(
    expr = standardize_names(model_parameters(x, ...), style = "broom"),
    error = function(e) NULL
  )


  if (is_null(m)) {
    m <- tryCatch(
      expr = standardize_names(model_parameters(x), style = "broom"),
      error = function(e) NULL
    )
  }

  # broom family --------------------------------------------

  # check if `{broom}` family has a tidy method for a given object
  if (is_null(m)) {
    m <- tryCatch(
      expr = broomExtra::tidy(x, conf.int = conf.int, ...),
      error = function(e) NULL
    )
  }

  # return the final object
  if (is_null(m)) m else as_tibble(m)
}


#' @name glance_performance
#' @title Model performance summary dataframes using `{broom}` and `{easystats}`
#'
#' @description
#'
#' Computes indices of model performance for regression models.
#'
#' @return A data frame (with one row) and one column per "index".
#'
#' @details The function will attempt to get these details either using
#'   [broom::glance()] or [performance::model_performance()]. If both function
#'   provide model performance measure summaries, the function will try to
#'   combine them into a single dataframe. Measures for which these two packages
#'   have different naming conventions, both will be retained.
#'
#' @inheritParams glance
#'
#' @examples
#'
#' set.seed(123)
#' mod <- lm(mpg ~ wt + cyl, data = mtcars)
#' broomExtra::glance_performance(mod)
#' @import performance
#'
#' @export

glance_performance <- function(x, ...) {
  # broom family --------------------------------------------
  # check if `{broom}` family has a tidy method for a given object
  df_broom <- tryCatch(broomExtra::glance(x, ...), error = function(e) NULL)

  # for consistency with `{performance}` output, convert column names to lowercase
  if (!is_null(df_broom)) df_broom %<>% rename_all(.funs = tolower)

  # easystats family ---------------------------------------
  # check if `{easystats}` family has a tidy method for a given object
  df_performance <- tryCatch(
    expr = standardize_names(model_performance(x, metrics = "all", ...), style = "broom"),
    error = function(e) NULL
  )

  # marry the families ---------------------------------------
  # combine if both are available
  if (!is_null(df_broom) && !is_null(df_performance)) {
    df_combined <- bind_cols(
      df_broom,
      select(df_performance, -intersect(names(df_broom), names(df_performance))),
    )
  }

  # otherwise return what's not a `NULL`
  if (is_null(df_broom)) df_combined <- df_performance
  if (is_null(df_performance)) df_combined <- df_broom

  # return the final object
  if (is_null(df_combined)) df_combined else as_tibble(df_combined)
}
