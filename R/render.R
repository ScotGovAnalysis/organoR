make_dot <- function(parts, theme) {
  nodes <- parts$nodes
  edges <- parts$edges
  node_lines <- purrr::pmap_chr(nodes, function(name, grade, profession, team, employee_id, vacancy_id, node_id, is_vacancy, is_or, ...) {
    if (is_vacancy) {
      label <- paste("Vacancy", grade, profession, sep = "\n")
      fill <- theme$vacancy_fill; colour <- theme$colours[[grade]]; style <- "filled,dashed"
    } else if (is_or) {
      label <- paste(name, grade, profession, sep = "\n")
      fill <- theme$colours[[grade]]; colour <- theme$colours[[grade]]; style <- "filled"
    } else {
      label <- paste(grade, profession, sep = "\n")
      fill <- "#FFFFFF"; colour <- theme$colours[[grade]]; style <- "filled"
    }
    paste0(dot_quote(node_id), " [label=", dot_quote(label), ", fillcolor=", dot_quote(fill), ", color=", dot_quote(colour), ", style=", dot_quote(style), "];")
  })
  edge_lines <- purrr::pmap_chr(edges, function(from, to, manager_type, ...) {
    style <- if (manager_type == "dotted") "dotted" else "solid"
    paste0(dot_quote(from), " -> ", dot_quote(to), " [style=", dot_quote(style), "];")
  })
  rank_lines <- purrr::map_chr(.grade_order, function(g) {
    ids <- nodes |> dplyr::filter(.data$grade == g) |> dplyr::pull(.data$node_id)
    if (!length(ids)) return("")
    paste0("{ rank=same; ", paste(dot_quote(ids), collapse = "; "), "; }")
  })
  paste(c("digraph organogram {", "graph [rankdir=TB, bgcolor=white, nodesep=0.35, ranksep=0.55];", paste0("node [shape=box, fontname=", dot_quote(theme$font), ", fontsize=10, margin=0.12];"), paste0("edge [color=", dot_quote("#4D4D4D"), ", penwidth=1.2, arrowsize=0.7];"), node_lines, edge_lines, rank_lines, "}"), collapse = "\n")
}

#' Render one team organogram
#'
#' @param data Organisational relationship data.
#' @param team Team to render.
#' @param theme Theme returned by [theme_scotgov()].
#' @return A DiagrammeR htmlwidget.
#' @export
#' @examples
#' x <- read_org_data(system.file("extdata", "simple_org.csv", package = "organoR"))
#' if (interactive() && nrow(x)) render_team_org(x, "Health")
render_team_org <- function(data, team, theme = theme_scotgov()) {
  parts <- get_team_subgraph(data, team)
  widget <- DiagrammeR::grViz(make_dot(parts, theme))
  attr(widget, "dot") <- make_dot(parts, theme)
  widget
}

#' Render all team organograms to HTML
#'
#' @param data Organisational relationship data.
#' @param output_file Destination HTML path.
#' @param theme Theme returned by [theme_scotgov()].
#'
#' @return `output_file`, invisibly.
#' @export
render_all_teams <- function(
    data,
    output_file,
    theme = theme_scotgov()
) {
  validate_org_data(data)
  
  if (
    length(output_file) != 1L ||
    is.na(output_file) ||
    !nzchar(output_file)
  ) {
    cli::cli_abort(
      "`output_file` must be a single, non-empty file path."
    )
  }
  
  output_file <- normalizePath(
    output_file,
    winslash = "/",
    mustWork = FALSE
  )
  
  output_dir <- dirname(output_file)
  
  if (!dir.exists(output_dir)) {
    dir.create(
      output_dir,
      recursive = TRUE,
      showWarnings = FALSE
    )
  }
  
  teams <- sort(unique(data$team))
  
  widgets <- purrr::map(
    teams,
    function(team) {
      htmltools::tagList(
        htmltools::tags$h2(team),
        render_team_org(
          data = data,
          team = team,
          theme = theme
        )
      )
    }
  )
  
  page <- htmltools::tags$html(
    htmltools::tags$head(
      htmltools::tags$meta(charset = "utf-8"),
      htmltools::tags$title(
        "organoR organograms"
      ),
      htmltools::tags$style(
        "
        body {
          font-family: Arial, sans-serif;
          margin: 2rem;
        }

        h1,
        h2 {
          color: #005EB8;
        }

        h2 {
          margin-top: 3rem;
        }
        "
      )
    ),
    htmltools::tags$body(
      htmltools::tags$h1("Organograms"),
      widgets
    )
  )
  
  file_stem <- tools::file_path_sans_ext(
    basename(output_file)
  )
  
  libdir <- file.path(
    output_dir,
    paste0(file_stem, "_files")
  )
  
  htmltools::save_html(
    html = htmltools::browsable(page),
    file = output_file,
    libdir = libdir,
    background = "white"
  )
  
  invisible(output_file)
}
