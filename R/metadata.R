#' Marginal Revolution post metadata
#'
#' Data frame containing metadata on Marginal Revolution blog posts.
#'
#' @docType data
#'
#' @usage data(metadata)
#'
#' @format Data frame with columns
#' \describe{
#' \item{path}{Post path}
#' \item{id}{Post ID}
#' \item{time}{Post publication time}
#' \item{title}{Post title}
#' \item{author}{Post author}
#' }
#'
#' @examples
#' metadata
#'
#' if (require("dplyr")) {
#' metadata %>% count(author)
#' }
#'
#' @source \href{https://marginalrevolution.com}{Marginal Revolution}
"metadata"
