#' @title Tidy output from grouped analysis of any function that has `data`
#'   argument in its function call.
#' @name grouped_tidy
#'
#' @param data Dataframe (or tibble) from which variables are to be taken.
#' @param grouping.vars Grouping variables.
#' @param ..f A function, or function name as a string.
#' @inheritParams rlang::exec
#' @param tidy.args A list of arguments to be used in the relevant `S3` method.
#'
#' @importFrom rlang !! !!! exec enquos
#' @importFrom dplyr group_by_at ungroup mutate group_modify
#'
#' @inherit tidy return value
#'
#' @seealso \code{\link{tidy}}
#'
#' @examples
#' set.seed(123)
#'
#' # linear mixed effects model
#' broomExtra::grouped_tidy(
#'   data = dplyr::mutate(MASS::Aids2, interval = death - diag),
#'   grouping.vars = sex,
#'   ..f = lme4::lmer,
#'   formula = interval ~ age + (1 | status),
#'   control = lme4::lmerControl(optimizer = "bobyqa"),
#'   tidy.args = list(conf.int = TRUE, conf.level = 0.99)
#' )
#' @export

# function body
grouped_tidy <- function(data,
                         grouping.vars,
                         ..f,
                         ...,
                         tidy.args = list()) {
  # functions passed to `group_modify` must accept
  # `.x` and `.y` arguments, where `.x` is the data
  tidy_group <- function(.x, .y) {
    # presumes `..f` will work with these args
    model <- ..f(.y = ..., data = .x)

    # variation on `do.call` to call function with list of arguments
    rlang::exec(broomExtra::tidy, model, !!!tidy.args)
  }

  # dataframe with grouped analysis results
  grouped_cleanup(data, rlang::enquos(grouping.vars), tidy_group)
}

#' @title Model summary output from grouped analysis of any function that has
#'   `data` argument in its function call.
#' @name grouped_glance
#'
#' @inheritParams grouped_tidy
#'
#' @importFrom rlang !! !!! exec enquos
#' @importFrom dplyr group_by_at ungroup mutate group_modify
#'
#' @inherit glance return value
#'
#' @seealso \code{\link{glance}}
#'
#' @examples
#' set.seed(123)
#'
#' # linear mixed effects model
#' broomExtra::grouped_glance(
#'   data = dplyr::mutate(MASS::Aids2, interval = death - diag),
#'   grouping.vars = sex,
#'   ..f = lme4::lmer,
#'   formula = interval ~ age + (1 | status),
#'   control = lme4::lmerControl(optimizer = "bobyqa")
#' )
#' @export

# function body
grouped_glance <- function(data,
                           grouping.vars,
                           ..f,
                           ...) {
  # functions passed to `group_modify` must accept
  # `.x` and `.y` arguments, where `.x` is the data
  glance_group <- function(.x, .y) {
    # presumes `..f` will work with these args
    model <- ..f(.y = ..., data = .x)

    # variation on `do.call` to call function with list of arguments
    rlang::exec(broomExtra::glance, model)
  }

  # dataframe with grouped analysis results
  grouped_cleanup(data, rlang::enquos(grouping.vars), glance_group)
}

#' @title Augmented data from grouped analysis of any function that has `data`
#'   argument in its function call.
#' @name grouped_augment
#'
#' @inheritParams grouped_tidy
#' @param augment.args A list of arguments to be used in the relevant `S3` method.
#'
#' @importFrom rlang !! !!! exec enquos
#' @importFrom dplyr group_by_at ungroup mutate group_modify
#'
#' @inherit augment return value
#'
#' @seealso \code{\link{augment}}
#'
#' @examples
#' set.seed(123)
#'
#' # linear mixed effects model
#' broomExtra::grouped_augment(
#'   data = dplyr::mutate(MASS::Aids2, interval = death - diag),
#'   grouping.vars = sex,
#'   ..f = lme4::lmer,
#'   formula = interval ~ age + (1 | status),
#'   control = lme4::lmerControl(optimizer = "bobyqa")
#' )
#' @export

# function body
grouped_augment <- function(data,
                            grouping.vars,
                            ..f,
                            ...,
                            augment.args = list()) {
  # functions passed to `group_modify` must accept
  # `.x` and `.y` arguments, where `.x` is the data
  augment_group <- function(.x, .y) {
    # presumes `..f` will work with these args
    model <- ..f(.y = ..., data = .x)

    # variation on `do.call` to call function with list of arguments
    rlang::exec(broomExtra::augment, model, !!!augment.args)
  }

  # dataframe with grouped analysis results
  grouped_cleanup(data, rlang::enquos(grouping.vars), augment_group)
}


#' @noRd

grouped_cleanup <- function(data, .vars, .f) {
  data %>%
    dplyr::group_by_at(.vars, .drop = TRUE) %>%
    dplyr::group_modify(.f) %>%
    dplyr::ungroup(.)
}
