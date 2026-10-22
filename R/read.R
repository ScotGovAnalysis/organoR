#' Read organisational relationship data
#'
#' @param path Path to a CSV file.
#' @return A tibble containing organisational relationships.
#' @export
#' @examples
#' path <- system.file("extdata", "simple_org.csv", package = "organoR")
#' if (nzchar(path)) read_org_data(path)
read_org_data <- function(path) {
  readr::read_csv(path, show_col_types = FALSE, na = c("", "NA")) |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(.required_columns), ~ stringr::str_trim(as.character(.x))),
      manager = dplyr::na_if(.data$manager, "")
    )
}
