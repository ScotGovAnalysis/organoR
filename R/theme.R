#' Scottish Government organogram theme
#'
#' Returns the default grade palette and retains `sgplot` as a mandatory
#' dependency for Scottish Government visual consistency.
#'
#' @param colours Optional named grade colour vector.
#' @return A list containing colours and styling constants.
#' @export
#' @examples theme_scotgov()
theme_scotgov <- function(colours = c(C3 = "#005EB8", C2 = "#2B7BBB", C1 = "#5B9BD5", B3 = "#A5A5A5", B2 = "#D0D0D0", B1 = "#EFEFEF")) {
  if (!requireNamespace("sgplot", quietly = TRUE)) abort_org("Package `sgplot` is required.")
  if (!all(.valid_grades %in% names(colours))) abort_org("`colours` must name all supported grades.")
  list(colours = colours[.valid_grades], vacancy_fill = "#FFF2CC", font = "Arial", sgplot_theme = sgplot::theme_sg())
}
