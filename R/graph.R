#' Build an organisational graph
#'
#' Employees receive deterministic IDs. Each vacancy relationship receives a
#' unique vacancy ID, allowing multiple vacancies with identical metadata.
#'
#' @param data Valid organisational relationship data.
#' @return A list containing `nodes`, `edges`, and a directed `igraph` object.
#' @export
#' @examples
#' x <- read_org_data(system.file("extdata", "simple_org.csv", package = "organoR"))
#' if (nrow(x)) build_graph(x)
build_graph <- function(data) {
  validate_org_data(data)
  data <- tibble::as_tibble(data) |> dplyr::mutate(.row = dplyr::row_number())
  people <- data |> dplyr::filter(.data$name != "Vacancy") |>
    dplyr::distinct(.data$name, .data$grade, .data$profession, .data$team) |>
    dplyr::arrange(.data$name, .data$grade, .data$profession, .data$team) |>
    dplyr::mutate(employee_id = sprintf("employee_%04d", dplyr::row_number()), vacancy_id = NA_character_, node_id = .data$employee_id)
  vacancies <- data |> dplyr::filter(.data$name == "Vacancy") |>
    dplyr::mutate(vacancy_id = sprintf("vacancy_%04d", dplyr::row_number()), employee_id = NA_character_, node_id = .data$vacancy_id) |>
    dplyr::select(.data$name, .data$grade, .data$profession, .data$team, .data$employee_id, .data$vacancy_id, .data$node_id, .data$.row)
  nodes <- dplyr::bind_rows(people |> dplyr::mutate(.row = NA_integer_), vacancies) |>
    dplyr::mutate(is_vacancy = .data$name == "Vacancy", is_or = .data$profession == "OR")
  name_ids <- people |> dplyr::select(.data$name, manager_id = .data$node_id)
  employee_ids <- people |> dplyr::select(.data$name, employee_node_id = .data$node_id)
  edges <- data |> dplyr::filter(!is.na(.data$manager)) |>
    dplyr::left_join(name_ids, by = c("manager" = "name")) |>
    dplyr::left_join(employee_ids, by = "name") |>
    dplyr::left_join(vacancies |> dplyr::select(.data$.row, vacancy_node_id = .data$node_id), by = ".row") |>
    dplyr::mutate(employee_id = dplyr::coalesce(.data$employee_node_id, .data$vacancy_node_id)) |>
    dplyr::transmute(from = .data$manager_id, to = .data$employee_id, manager_type = .data$manager_type) |>
    dplyr::distinct()
  graph <- igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes |> dplyr::transmute(name = .data$node_id))
  list(nodes = nodes |> dplyr::select(-.data$.row), edges = edges, graph = graph)
}

#' Extract a team and its recursive managers
#'
#' @param data Valid organisational relationship data.
#' @param team A single team name.
#' @return A list with nodes, edges and graph for the team and all ancestors.
#' @export
#' @examples
#' x <- read_org_data(system.file("extdata", "matrix_org.csv", package = "organoR"))
#' if (nrow(x)) get_team_subgraph(x, "Health")
get_team_subgraph <- function(data, team) {
  team_current = team
  built <- build_graph(data)
  browser()
  seeds <- built$nodes |> dplyr::filter(.data$team == team_current) |> dplyr::pull(node_id)
  browser()
  if (!length(seeds)) abort_org(paste0("Unknown team: ", team))
  ancestors <- unique(unlist(igraph::ego(built$graph, order = Inf, nodes = seeds, mode = "in")))
  ids <- igraph::V(built$graph)$name[ancestors]
  nodes <- built$nodes |> dplyr::filter(.data$node_id %in% ids)
  edges <- built$edges |> dplyr::filter(.data$from %in% ids, .data$to %in% ids)
  graph <- igraph::induced_subgraph(built$graph, vids = ids)
  list(nodes = nodes, edges = edges, graph = graph)
}
