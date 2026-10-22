#' Validate organisational relationship data
#'
#' Checks schema, supported grades and relationship types, consistent employee
#' metadata, manager references, cycles and grade anomalies. Additional
#' professions are accepted with a warning.
#'
#' @param data A data frame in organoR relationship format.
#' @return A validated tibble, invisibly.
#' @export
#' @examples
#' x <- tibble::tribble(
#'   ~name, ~grade, ~profession, ~team, ~manager, ~manager_type,
#'   "Director", "C3", "OR", "Health", NA, "line",
#'   "Analyst", "C1", "OR", "Health", "Director", "line"
#' )
#' validate_org_data(x)
validate_org_data <- function(data) {
  data <- tibble::as_tibble(data)
  missing <- setdiff(.required_columns, names(data))
  if (length(missing)) abort_org(paste("Missing required columns:", paste(missing, collapse = ", ")))
  data <- data |>
    dplyr::mutate(dplyr::across(dplyr::all_of(.required_columns), as.character), manager = dplyr::na_if(.data$manager, ""))
  if (any(is.na(data$name) | data$name == "")) abort_org("`name` must not be missing or blank.")
  bad_grades <- setdiff(stats::na.omit(unique(data$grade)), .valid_grades)
  if (length(bad_grades)) abort_org(paste("Invalid grades:", paste(bad_grades, collapse = ", ")))
  bad_types <- setdiff(stats::na.omit(unique(data$manager_type)), .valid_manager_types)
  if (length(bad_types)) abort_org(paste("Invalid manager types:", paste(bad_types, collapse = ", ")))
  unknown_prof <- setdiff(stats::na.omit(unique(data$profession)), .valid_professions)
  if (length(unknown_prof)) warn_org(paste("Additional professions:", paste(unknown_prof, collapse = ", ")))

  employees <- data |> dplyr::filter(.data$name != "Vacancy") |>
    dplyr::distinct(.data$name, .data$grade, .data$profession, .data$team)
  inconsistent <- employees |> dplyr::count(.data$name) |> dplyr::filter(.data$n > 1)
  if (nrow(inconsistent)) abort_org(paste("Inconsistent employee metadata for:", paste(inconsistent$name, collapse = ", ")))
  missing_mgr <- setdiff(stats::na.omit(unique(data$manager)), unique(data$name))
  if (length(missing_mgr)) abort_org(paste("Managers not found:", paste(missing_mgr, collapse = ", ")))

  edges <- data |> dplyr::filter(!is.na(.data$manager)) |> dplyr::distinct(.data$manager, .data$name)
  g <- igraph::graph_from_data_frame(edges, directed = TRUE, vertices = unique(data$name))
  if (!igraph::is_dag(g)) abort_org("Circular management relationships detected.")

  grade_index <- stats::setNames(seq_along(.grade_order), .grade_order)
  employee_grades <- data |> dplyr::filter(.data$name != "Vacancy") |>
    dplyr::distinct(.data$name, .data$grade)
  anomalies <- data |> dplyr::filter(!is.na(.data$manager)) |>
    dplyr::left_join(employee_grades, by = c("manager" = "name"), suffix = c("_employee", "_manager")) |>
    dplyr::filter(!is.na(.data$grade_manager), grade_index[.data$grade_manager] > grade_index[.data$grade_employee])
  if (nrow(anomalies)) warn_org("At least one manager has a lower grade than the employee.")
  invisible(data)
}
