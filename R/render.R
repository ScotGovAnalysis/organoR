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
#' @param show_legend Logical. If `TRUE`, display the colour legend above the
#'   organogram.
#'
#' @return A DiagrammeR htmlwidget.
#' @export
render_team_org <- function(
    data,
    team,
    theme = theme_scotgov(), 
    show_legend = TRUE
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
  
  if (!isTRUE(show_legend)) {
    return(widget)
  }
  
  htmltools::browsable(
    htmltools::tagList(
      organogram_css(),
      make_colour_legend(theme),
      htmltools::tags$div(
        class = "organogram-container",
        widget
      )
    )
  )
  
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
            theme = theme, 
            show_legend = FALSE
          )
        )
      )
    }
  )
  
  page <- htmltools::tags$html(
    htmltools::tags$head(
      htmltools::tags$meta(charset = "utf-8"),
      htmltools::tags$title("organoR organograms"),
      organogram_css(),
      htmltools::tags$style(
        "
      body {
        font-family: Arial, sans-serif;
        margin: 2rem;
      }

      h1,
      h2 {
        color: #005EB8;
        text-align: center;
      }

      h2 {
        margin-top: 3rem;
      }
      "
      )
    ),
    
    htmltools::tags$body(
      htmltools::tags$h1("Organograms"),
      make_colour_legend(theme),
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

make_colour_legend <- function(theme) {
  grade_order <- rev(.grade_order)
  
  grade_items <- purrr::map(
    grade_order,
    function(grade) {
      htmltools::tags$div(
        class = "organogram-legend-item",
        
        htmltools::tags$span(
          class = "organogram-legend-swatch",
          style = htmltools::css(
            background_color = theme$colours[[grade]],
            border_color = theme$colours[[grade]]
          ),
          `aria-hidden` = "true"
        ),
        
        htmltools::tags$span(
          class = "organogram-legend-label",
          grade
        )
      )
    }
  )
  
  node_type_items <- list(
    htmltools::tags$div(
      class = "organogram-legend-item",
      
      htmltools::tags$span(
        class = "organogram-legend-swatch",
        style = htmltools::css(
          background_color = theme$colours[["C2"]],
          border_color = theme$colours[["C2"]]
        ),
        `aria-hidden` = "true"
      ),
      
      htmltools::tags$span(
        class = "organogram-legend-label",
        "OR"
      )
    ),
    
    htmltools::tags$div(
      class = "organogram-legend-item",
      
      htmltools::tags$span(
        class = "organogram-legend-swatch",
        style = htmltools::css(
          background_color = "#FFFFFF",
          border_color = theme$colours[["C2"]]
        ),
        `aria-hidden` = "true"
      ),
      
      htmltools::tags$span(
        class = "organogram-legend-label",
        "Non-OR"
      )
    ),
    
    htmltools::tags$div(
      class = "organogram-legend-item",
      
      htmltools::tags$span(
        class = paste(
          "organogram-legend-swatch",
          "organogram-legend-swatch-vacancy"
        ),
        style = htmltools::css(
          background_color = theme$vacancy_fill,
          border_color = "#4D4D4D"
        ),
        `aria-hidden` = "true"
      ),
      
      htmltools::tags$span(
        class = "organogram-legend-label",
        "Vacancy"
      )
    )
  )
  
  htmltools::tags$div(
    class = "organogram-legend",
    role = "group",
    `aria-label` = paste(
      "Organogram legend showing grade colours",
      "and node types"
    ),
    
    htmltools::tags$div(
      class = "organogram-legend-section",
      
      htmltools::tags$div(
        class = "organogram-legend-title",
        "Grade"
      ),
      
      htmltools::tags$div(
        class = "organogram-legend-items",
        grade_items
      )
    ),
    
    htmltools::tags$div(
      class = "organogram-legend-section",
      
      htmltools::tags$div(
        class = "organogram-legend-title",
        "Node type"
      ),
      
      htmltools::tags$div(
        class = "organogram-legend-items",
        node_type_items
      )
    )
  )
}

organogram_css <- function() {
  htmltools::tags$style(
    "
      .organogram-container {
        width: 100%;
        overflow-x: auto;
        overflow-y: visible;
        padding: 1rem 0;
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
  
      .organogram-legend {
    display: flex;
    align-items: flex-start;
    justify-content: center;
    flex-wrap: wrap;
    gap: 1.5rem 2rem;
  
    width: fit-content;
    max-width: 100%;
    margin: 1rem auto 2rem auto;
    padding: 1rem 1.25rem;
  
    border: 1px solid #D9D9D9;
    border-radius: 0.25rem;
    background-color: #FFFFFF;
    font-family: Arial, sans-serif;
  }
  
  .organogram-legend-section {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  
  .organogram-legend-title {
    font-weight: 700;
  }
  
  .organogram-legend-items {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-wrap: wrap;
    gap: 0.5rem 1rem;
  }
  
  .organogram-legend-item {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    white-space: nowrap;
  }
  
  .organogram-legend-swatch {
    display: inline-block;
    box-sizing: border-box;
  
    width: 1.25rem;
    height: 1.25rem;
  
    flex: 0 0 auto;
    border-width: 2px;
    border-style: solid;
    border-radius: 0.15rem;
  }
  
  .organogram-legend-swatch-vacancy {
    border-style: dashed;
  }
  
  .organogram-legend-label {
    font-size: 0.9rem;
  }
    "
  )
}
