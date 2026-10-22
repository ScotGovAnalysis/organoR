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
#'
#' @return A DiagrammeR htmlwidget.
#' @export
render_team_org <- function(
    data,
    team,
    theme = theme_scotgov()
) {
  parts <- get_team_subgraph(
    data = data,
    team = team
  )
  
  dot <- make_dot(
    parts = parts,
    theme = theme
  )
  
  widget <- DiagrammeR::grViz(
    diagram = dot,
    width = NULL,
    height = NULL
  )
  
  widget <- htmlwidgets::onRender(
    widget,
    "
    function(el, x) {
      function setNaturalSize() {
        const svg = el.querySelector('svg');

        if (!svg) {
          return false;
        }

        const viewBox = svg.viewBox.baseVal;

        if (
          !viewBox ||
          !Number.isFinite(viewBox.width) ||
          !Number.isFinite(viewBox.height) ||
          viewBox.width <= 0 ||
          viewBox.height <= 0
        ) {
          return false;
        }

        /*
         * GraphViz viewBox values correspond to typographical
         * points. Convert them to CSS pixels.
         */
        const pointToPixel = 96 / 72;

        const widthPixels = Math.ceil(
          viewBox.width * pointToPixel
        );

        const heightPixels = Math.ceil(
          viewBox.height * pointToPixel
        );

        /*
         * DiagrammeR normally gives the SVG percentage dimensions,
         * causing every graph to fill its htmlwidget container.
         * Replace those dimensions with the natural graph size.
         */
        svg.setAttribute('width', widthPixels);
        svg.setAttribute('height', heightPixels);

        svg.style.setProperty(
          'width',
          widthPixels + 'px',
          'important'
        );

        svg.style.setProperty(
          'height',
          heightPixels + 'px',
          'important'
        );

        svg.style.setProperty(
          'max-width',
          'none',
          'important'
        );

        svg.style.setProperty(
          'display',
          'block',
          'important'
        );

        /*
         * Resize the htmlwidget container as well, because its
         * default dimensions would otherwise continue to determine
         * the displayed graph size.
         */
        el.style.setProperty(
          'width',
          widthPixels + 'px',
          'important'
        );

        el.style.setProperty(
          'height',
          heightPixels + 'px',
          'important'
        );

        el.style.setProperty(
          'max-width',
          'none',
          'important'
        );

        el.style.setProperty(
          'overflow',
          'visible',
          'important'
        );

        return true;
      }

      /*
       * onRender can execute before viz.js has inserted the SVG.
       * Retry until the SVG and its viewBox are available.
       */
      let attempts = 0;

      const interval = window.setInterval(
        function() {
          attempts += 1;

          if (setNaturalSize() || attempts >= 50) {
            window.clearInterval(interval);
          }
        },
        20
      );
    }
    "
  )
  
  attr(widget, "dot") <- dot
  
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
        htmltools::tags$div(
          class = "organogram-container",
          render_team_org(
            data = data,
            team = team,
            theme = theme
          )
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
    
      .organogram-container {
        width: 100%;
        overflow-x: auto;
        overflow-y: visible;
        padding: 1rem 0;
    
        /*
         * Centre the widget when it is narrower than the plotting panel.
         */
        display: flex;
        justify-content: center;
      }
    
      .organogram-container .html-widget {
        display: block !important;
        flex: 0 0 auto;
        max-width: none !important;
        min-width: 0 !important;
      }
    
      .organogram-container svg {
        display: block !important;
        max-width: none !important;
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
