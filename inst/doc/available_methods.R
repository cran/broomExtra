## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(broomExtra)

## ----list, echo = FALSE, message = FALSE--------------------------------------
# loading the needed libraries
library(dplyr)
library(broom)
library(broom.mixed)

# function to extract methods
method_df <- function(method_name) {
  m <- as.vector(methods(method_name))
  dplyr::tibble(
    class = gsub(
      x = m,
      pattern = paste(method_name, "[.]", sep = ""),
      replacement = ""
    ),
    !!method_name := "x"
  )
}

# preparing a table
method_df("tidy") %>%
  dplyr::left_join(x = ., y = method_df("glance")) %>%
  dplyr::left_join(x = ., y = method_df("augment")) %>%
  dplyr::mutate_all(.tbl = ., .funs = tidyr::replace_na, "") %>%
  knitr::kable()

