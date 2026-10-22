# Getting Started with organoR

## Introduction

`organoR` creates organisational charts from tidy
management-relationship data.

It supports line and dotted management, vacancies, cross-team managers,
multiple managers and profession-specific shading.

The main workflow is:

1.  read the data;
2.  validate its structure;
3.  construct the organisational graph;
4.  extract a team subgraph;
5.  render one team or all teams; and
6.  optionally shade one selected profession.

``` r

library(organoR)
```

## Example organisation

The package contains a complex example dataset:

``` r

complex_path <- system.file(
  "extdata",
  "complex_org.csv",
  package = "organoR"
)

org <- read_org_data(complex_path)

org
#> # A tibble: 14 × 6
#>    name              grade profession        team      manager      manager_type
#>    <chr>             <chr> <chr>             <chr>     <chr>        <chr>       
#>  1 Chief Analyst     C3    OR                Corporate NA           line        
#>  2 Health Head       C2    OR                Health    Chief Analy… line        
#>  3 Justice Head      C2    Economist         Justice   Chief Analy… line        
#>  4 Education Head    C2    OR                Education Chief Analy… line        
#>  5 Health Lead       C1    Statistician      Health    Health Head  line        
#>  6 Health Analyst    B3    OR                Health    Health Lead  line        
#>  7 Health Analyst    B3    OR                Health    Justice Head dotted      
#>  8 Health Officer    B2    Social Researcher Health    Health Lead  line        
#>  9 Justice Lead      C1    OR                Justice   Justice Head line        
#> 10 Justice Analyst   B3    Economist         Justice   Justice Lead line        
#> 11 Education Lead    C1    OR                Education Education H… line        
#> 12 Education Analyst B3    OR                Education Education L… line        
#> 13 Vacancy           B2    OR                Health    Health Lead  line        
#> 14 Vacancy           B3    Statistician      Justice   Justice Lead line
```

The data has one row for each management relationship.

The required columns are:

- `name`;
- `grade`;
- `profession`;
- `team`;
- `manager`; and
- `manager_type`.

An employee with both a line manager and a dotted manager appears on
multiple rows. Employee attributes must remain consistent across those
rows.

A vacancy is represented by setting `name` to `"Vacancy"`.

## Validate the input

Validate the data before rendering:

``` r

validate_org_data(org)
```

Validation checks for missing columns, invalid grades, invalid
management types, inconsistent employee attributes, missing managers and
cycles.

## Build the complete graph

Construct the full organisational graph with:

``` r

graph_parts <- build_graph(org)

graph_parts$nodes
#> # A tibble: 13 × 8
#>    name         grade profession team  employee_id vacancy_id node_id is_vacancy
#>    <chr>        <chr> <chr>      <chr> <chr>       <chr>      <chr>   <lgl>     
#>  1 Chief Analy… C3    OR         Corp… employee_0… NA         employ… FALSE     
#>  2 Education A… B3    OR         Educ… employee_0… NA         employ… FALSE     
#>  3 Education H… C2    OR         Educ… employee_0… NA         employ… FALSE     
#>  4 Education L… C1    OR         Educ… employee_0… NA         employ… FALSE     
#>  5 Health Anal… B3    OR         Heal… employee_0… NA         employ… FALSE     
#>  6 Health Head  C2    OR         Heal… employee_0… NA         employ… FALSE     
#>  7 Health Lead  C1    Statistic… Heal… employee_0… NA         employ… FALSE     
#>  8 Health Offi… B2    Social Re… Heal… employee_0… NA         employ… FALSE     
#>  9 Justice Ana… B3    Economist  Just… employee_0… NA         employ… FALSE     
#> 10 Justice Head C2    Economist  Just… employee_0… NA         employ… FALSE     
#> 11 Justice Lead C1    OR         Just… employee_0… NA         employ… FALSE     
#> 12 Vacancy      B2    OR         Heal… NA          vacancy_0… vacanc… TRUE      
#> 13 Vacancy      B3    Statistic… Just… NA          vacancy_0… vacanc… TRUE
graph_parts$edges
#> # A tibble: 13 × 3
#>    from          to            manager_type
#>    <chr>         <chr>         <chr>       
#>  1 employee_0001 employee_0006 line        
#>  2 employee_0001 employee_0010 line        
#>  3 employee_0001 employee_0003 line        
#>  4 employee_0006 employee_0007 line        
#>  5 employee_0007 employee_0005 line        
#>  6 employee_0010 employee_0005 dotted      
#>  7 employee_0007 employee_0008 line        
#>  8 employee_0010 employee_0011 line        
#>  9 employee_0011 employee_0009 line        
#> 10 employee_0003 employee_0004 line        
#> 11 employee_0004 employee_0002 line        
#> 12 employee_0007 vacancy_0001  line        
#> 13 employee_0011 vacancy_0002  line
```

The returned object also contains an `igraph` object:

``` r

graph_parts$graph
#> IGRAPH e51f3fa DN-- 13 13 -- 
#> + attr: name (v/c), manager_type (e/c)
#> + edges from e51f3fa (vertex names):
#>  [1] employee_0001->employee_0006 employee_0001->employee_0010
#>  [3] employee_0001->employee_0003 employee_0006->employee_0007
#>  [5] employee_0007->employee_0005 employee_0010->employee_0005
#>  [7] employee_0007->employee_0008 employee_0010->employee_0011
#>  [9] employee_0011->employee_0009 employee_0003->employee_0004
#> [11] employee_0004->employee_0002 employee_0007->vacancy_0001 
#> [13] employee_0011->vacancy_0002
```

[`build_graph()`](https://scotgovanalysis.github.io/organoR/reference/build_graph.md)
generates deterministic employee identifiers and unique vacancy
identifiers.

## Extract one team

Use
[`get_team_subgraph()`](https://scotgovanalysis.github.io/organoR/reference/get_team_subgraph.md)
to extract a team and all managers required to connect its hierarchy:

``` r

health_graph <- get_team_subgraph(
  data = org,
  team = "Health"
)

health_graph$nodes
#> # A tibble: 7 × 8
#>   name          grade profession team  employee_id vacancy_id node_id is_vacancy
#>   <chr>         <chr> <chr>      <chr> <chr>       <chr>      <chr>   <lgl>     
#> 1 Chief Analyst C3    OR         Corp… employee_0… NA         employ… FALSE     
#> 2 Health Analy… B3    OR         Heal… employee_0… NA         employ… FALSE     
#> 3 Health Head   C2    OR         Heal… employee_0… NA         employ… FALSE     
#> 4 Health Lead   C1    Statistic… Heal… employee_0… NA         employ… FALSE     
#> 5 Health Offic… B2    Social Re… Heal… employee_0… NA         employ… FALSE     
#> 6 Justice Head  C2    Economist  Just… employee_0… NA         employ… FALSE     
#> 7 Vacancy       B2    OR         Heal… NA          vacancy_0… vacanc… TRUE
```

Managers from another team are retained if they are ancestors of an
employee in the selected team. Unrelated employees from other teams are
excluded.

## Render without profession shading

The default is to leave all occupied positions white:

``` r

render_team_org(
  data = org,
  team = "Health",
  shaded_profession = NULL
)
```

Grade

B1

B2

B3

C1

C2

C3

Node type

All professions

Vacancy

Although occupied positions are unshaded, their borders retain the
colour associated with their grade.

Vacancies continue to use the dedicated vacancy style.

## Shade a selected profession

Set `shaded_profession` to a single profession name to fill that
profession’s nodes with the corresponding grade colour.

For example, shade operational research positions:

``` r

render_team_org(
  data = org,
  team = "Health",
  shaded_profession = "OR"
)
```

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

Other professions remain white.

The legend identifies:

- grade colours;
- the shaded profession;
- other professions; and
- vacancies.

## Shade a different profession

The package does not treat operational research as intrinsically
different from other professions.

For example, shade statistician positions with:

``` r

render_team_org(
  data = org,
  team = "Health",
  shaded_profession = "Statistician"
)
```

Grade

B1

B2

B3

C1

C2

C3

Node type

Statistician profession

Other professions

Vacancy

The same graph can therefore be rendered for different professional
audiences without changing the underlying data.

## Suppress the legend

An individually rendered graph displays its legend by default.

Suppress it with:

``` r

render_team_org(
  data = org,
  team = "Health",
  shaded_profession = "OR",
  show_legend = FALSE
)
```

This is useful when the graph is embedded in a document that already
defines the visual encodings.

## Render all teams

Use
[`render_all_teams()`](https://scotgovanalysis.github.io/organoR/reference/render_all_teams.md)
to create one HTML page containing every team:

``` r

render_all_teams(
  data = org,
  output_file = "all-organograms.html",
  shaded_profession = "OR"
)
```

Only one legend is shown, at the top of the page.

The output consists of:

``` text
all-organograms.html
all-organograms_files/
```

The dependency directory must be retained with the HTML file.

## Compare shading choices

The same organisation can be rendered several ways.

### All professions unshaded

``` r

render_all_teams(
  data = org,
  output_file = "all-organograms-unshaded.html",
  shaded_profession = NULL
)
```

### Operational research shaded

``` r

render_all_teams(
  data = org,
  output_file = "all-organograms-or.html",
  shaded_profession = "OR"
)
```

### Economists shaded

``` r

render_all_teams(
  data = org,
  output_file = "all-organograms-economist.html",
  shaded_profession = "Economist"
)
```

### Social researchers shaded

``` r

render_all_teams(
  data = org,
  output_file = "all-organograms-social-research.html",
  shaded_profession = "Social Researcher"
)
```

The setting changes only node fill and legend text. It does not alter
the organisation, node borders, management relationships or layout.

## Visual encodings

The rendered graphs use the following encodings:

- grade controls border colour;
- the selected profession receives solid grade-coloured fill;
- other occupied positions receive white fill;
- vacancies receive the vacancy fill and a dashed border;
- line management uses solid edges; and
- dotted management uses dotted edges.

Separating these encodings allows grade, profession, vacancy status and
management type to be interpreted independently.

## Custom colours

Create a custom theme by supplying a named grade palette:

``` r

custom_theme <- theme_scotgov(
  colours = c(
    C3 = "#003B5C",
    C2 = "#0065BD",
    C1 = "#4A90C2",
    B3 = "#8FB7D4",
    B2 = "#C2D8E8",
    B1 = "#E8F1F7"
  )
)
```

Use it when rendering:

``` r

render_team_org(
  data = org,
  team = "Health",
  theme = custom_theme,
  shaded_profession = "OR"
)
```

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

The selected profession is filled with the custom grade colour.

## Complete workflow

A typical analysis script is:

``` r

library(organoR)

org <- read_org_data(
  "complex_org.csv"
)

validate_org_data(org)

graph_parts <- build_graph(org)

health_graph <- get_team_subgraph(
  data = org,
  team = "Health"
)

render_team_org(
  data = org,
  team = "Health",
  shaded_profession = "OR"
)

render_all_teams(
  data = org,
  output_file = "all-organograms.html",
  shaded_profession = "OR"
)
```
