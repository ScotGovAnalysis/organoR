# Render all team organograms to HTML

Creates an HTML page containing one organogram for every team. A single
colour legend is displayed above the collection of graphs.

## Usage

``` r
render_all_teams(
  data,
  output_file,
  theme = theme_scotgov(),
  shaded_profession = NULL
)
```

## Arguments

- data:

  Organisational relationship data.

- output_file:

  Path to the destination HTML file.

- theme:

  Theme returned by
  [`theme_scotgov()`](https://scotgovanalysis.github.io/organoR/reference/theme_scotgov.md).

- shaded_profession:

  Either `NULL` or a single profession name. Nodes belonging to this
  profession receive a solid grade-coloured fill. If `NULL`, all
  occupied position nodes have a white fill.

## Value

The normalised output path, invisibly.

## Examples

``` r
path <- system.file(
  "extdata",
  "complex_org.csv",
  package = "organoR"
)

if (nzchar(path) && interactive()) {
  org <- read_org_data(path)

  render_all_teams(
    data = org,
    output_file = tempfile(fileext = ".html"),
    shaded_profession = "OR"
  )
}
```
