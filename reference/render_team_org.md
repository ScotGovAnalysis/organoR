# Render one team organogram

Creates an interactive organogram for a selected team. Managers from
other teams are included when they are required to connect the
hierarchy.

## Usage

``` r
render_team_org(
  data,
  team,
  theme = theme_scotgov(),
  shaded_profession = NULL,
  show_legend = TRUE
)
```

## Arguments

- data:

  Organisational relationship data.

- team:

  A single team name.

- theme:

  Theme returned by
  [`theme_scotgov()`](https://scotgovanalysis.github.io/organoR/reference/theme_scotgov.md).

- shaded_profession:

  Either `NULL` or a single profession name. Nodes belonging to this
  profession receive a solid grade-coloured fill. If `NULL`, all
  occupied position nodes have a white fill.

- show_legend:

  Logical. If `TRUE`, display the colour legend above the organogram.

## Value

A DiagrammeR htmlwidget when `show_legend` is `FALSE`; otherwise, a
browsable HTML component containing the legend and organogram.

## Examples

``` r
path <- system.file(
  "extdata",
  "complex_org.csv",
  package = "organoR"
)

if (nzchar(path)) {
  org <- read_org_data(path)

  render_team_org(
    data = org,
    team = "Health",
    shaded_profession = "OR"
  )
}

    .organogram-container {
      box-sizing: border-box;
      width: 100%;
      overflow-x: auto;
      overflow-y: visible;
      padding: 1rem 0;

      display: flex;
      flex-direction: row;
      justify-content: center;
      align-items: flex-start;
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
    

  
    Grade
    
      
        
        B1
      
      
        
        B2
      
      
        
        B3
      
      
        
        C1
      
      
        
        C2
      
      
        
        C3
      
    
  
  
    Node type
    
      
        
        OR profession
      
      
        
        Other professions
      
      
        
        Vacancy
      
    
  


  
  {"x":{"diagram":"digraph organogram {\ngraph [rankdir=TB, bgcolor=white, nodesep=0.35, ranksep=0.55, splines=polyline, outputorder=edgesfirst];\nnode [shape=box, fontname=\"Arial\", fontsize=10, margin=0.12];\nedge [color=\"#4D4D4D\", penwidth=1.2, arrowsize=0.7];\n\"employee_0001\" [label=\"Chief Analyst\\nC3\\nOR\", fillcolor=\"#005EB8\", color=\"#005EB8\", style=\"filled\"];\n\"employee_0005\" [label=\"Health Analyst\\nB3\\nOR\", fillcolor=\"#A5A5A5\", color=\"#A5A5A5\", style=\"filled\"];\n\"employee_0006\" [label=\"Health Head\\nC2\\nOR\", fillcolor=\"#2B7BBB\", color=\"#2B7BBB\", style=\"filled\"];\n\"employee_0007\" [label=\"Health Lead\\nC1\\nStatistician\", fillcolor=\"#FFFFFF\", color=\"#5B9BD5\", style=\"filled\"];\n\"employee_0008\" [label=\"Health Officer\\nB2\\nSocial Researcher\", fillcolor=\"#FFFFFF\", color=\"#D0D0D0\", style=\"filled\"];\n\"employee_0010\" [label=\"Justice Head\\nC2\\nEconomist\", fillcolor=\"#FFFFFF\", color=\"#2B7BBB\", style=\"filled\"];\n\"vacancy_0001\" [label=\"Vacancy\\nB2\\nOR\", fillcolor=\"#FFF2CC\", color=\"#D0D0D0\", style=\"filled,dashed\"];\n\"employee_0001\" -> \"employee_0006\" [style=\"solid\", constraint=true];\n\"employee_0001\" -> \"employee_0010\" [style=\"solid\", constraint=true];\n\"employee_0006\" -> \"employee_0007\" [style=\"solid\", constraint=true];\n\"employee_0007\" -> \"employee_0005\" [style=\"solid\", constraint=true];\n\"employee_0010\" -> \"employee_0005\" [style=\"dotted\", constraint=true];\n\"employee_0007\" -> \"employee_0008\" [style=\"solid\", constraint=true];\n\"employee_0007\" -> \"vacancy_0001\" [style=\"solid\", constraint=true];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":{"render":[{"code":"\n    function(el, x) {\n      function setNaturalSize() {\n        const svg = el.querySelector('svg');\n\n        if (!svg) {\n          return false;\n        }\n\n        const viewBox = svg.viewBox.baseVal;\n\n        if (\n          !viewBox ||\n          !Number.isFinite(viewBox.width) ||\n          !Number.isFinite(viewBox.height) ||\n          viewBox.width <= 0 ||\n          viewBox.height <= 0\n        ) {\n          return false;\n        }\n\n        const pointToPixel = 96 / 72;\n\n        const widthPixels = Math.ceil(\n          viewBox.width * pointToPixel\n        );\n\n        const heightPixels = Math.ceil(\n          viewBox.height * pointToPixel\n        );\n\n        svg.setAttribute('width', widthPixels);\n        svg.setAttribute('height', heightPixels);\n\n        svg.style.setProperty(\n          'width',\n          widthPixels + 'px',\n          'important'\n        );\n\n        svg.style.setProperty(\n          'height',\n          heightPixels + 'px',\n          'important'\n        );\n\n        svg.style.setProperty(\n          'max-width',\n          'none',\n          'important'\n        );\n\n        svg.style.setProperty(\n          'display',\n          'block',\n          'important'\n        );\n\n        el.style.setProperty(\n          'width',\n          widthPixels + 'px',\n          'important'\n        );\n\n        el.style.setProperty(\n          'height',\n          heightPixels + 'px',\n          'important'\n        );\n\n        el.style.setProperty(\n          'max-width',\n          'none',\n          'important'\n        );\n\n        el.style.setProperty(\n          'overflow',\n          'visible',\n          'important'\n        );\n\n        return true;\n      }\n\n      let attempts = 0;\n\n      const interval = window.setInterval(\n        function() {\n          attempts += 1;\n\n          if (setNaturalSize() || attempts >= 50) {\n            window.clearInterval(interval);\n          }\n        },\n        20\n      );\n    }\n    ","data":null}]}}
```
