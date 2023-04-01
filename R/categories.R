#' Marginal Revolution post categories
#'
#' Data frame containing post ID-category pairs.
#'
#' @docType data
#'
#' @usage data(categories)
#'
#' @format Data frame with columns
#' \describe{
#' \item{id}{Post ID}
#' \item{category}{Post category}
#' }
#'
#' @examples
#' categories
#'
#' if (require("dplyr")) {
#' categories %>% count(category)
#' }
#'
#' @source \href{https://marginalrevolution.com}{Marginal Revolution}
"categories"
