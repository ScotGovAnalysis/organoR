test_that("DOT applies node and edge styling rules", {
  x <- dplyr::bind_rows(
    make_org(),
    tibble::tibble(
      name = "Vacancy",
      grade = "B3",
      profession = "OR",
      team = "Health",
      manager = "Lead",
      manager_type = "line"
    )
  )
  
  dot <- organoR:::make_dot(
    parts = get_team_subgraph(
      data = x,
      team = "Health"
    ),
    theme = theme_scotgov(),
    shaded_profession = NULL
  )
  
  # The graph uses a vertical, top-to-bottom layout.
  expect_match(
    dot,
    "rankdir=TB",
    fixed = TRUE
  )
  
  # Grade rank constraints were deliberately removed because they
  # caused nodes to be arranged horizontally.
  expect_false(
    grepl(
      "rank=same",
      dot,
      fixed = TRUE
    )
  )
  
  # Dotted management relationships remain dotted.
  expect_match(
    dot,
    'style="dotted"',
    fixed = TRUE
  )
  
  # Vacancies retain their specified fill and dashed outline.
  expect_match(
    dot,
    theme_scotgov()$vacancy_fill,
    fixed = TRUE
  )
  
  expect_match(
    dot,
    'style="filled,dashed"',
    fixed = TRUE
  )
  
  # Names, grades and professions are shown for occupied nodes.
  expect_match(
    dot,
    "Lead\\nC2\\nStatistician",
    fixed = TRUE
  )
  
  # No profession is shaded when shaded_profession is NULL.
  expect_match(
    dot,
    paste0(
      'label="Lead\\nC2\\nStatistician", ',
      'fillcolor="#FFFFFF"'
    ),
    fixed = TRUE
  )
})


test_that("selected profession receives grade-coloured shading", {
  dot <- organoR:::make_dot(
    parts = get_team_subgraph(
      data = make_org(),
      team = "Health"
    ),
    theme = theme_scotgov(),
    shaded_profession = "Statistician"
  )
  
  expect_match(
    dot,
    paste0(
      'label="Lead\\nC2\\nStatistician", ',
      'fillcolor="#2B7BBB"'
    ),
    fixed = TRUE
  )
  
  # Professions other than the selected profession remain empty.
  expect_match(
    dot,
    paste0(
      'label="Analyst\\nC1\\nOR", ',
      'fillcolor="#FFFFFF"'
    ),
    fixed = TRUE
  )
})


test_that("OR can be selected as the shaded profession", {
  dot <- organoR:::make_dot(
    parts = get_team_subgraph(
      data = make_org(),
      team = "Health"
    ),
    theme = theme_scotgov(),
    shaded_profession = "OR"
  )
  
  expect_match(
    dot,
    paste0(
      'label="Analyst\\nC1\\nOR", ',
      'fillcolor="#5B9BD5"'
    ),
    fixed = TRUE
  )
  
  expect_match(
    dot,
    paste0(
      'label="Lead\\nC2\\nStatistician", ',
      'fillcolor="#FFFFFF"'
    ),
    fixed = TRUE
  )
})


test_that("invalid shaded profession arguments are rejected", {
  parts <- get_team_subgraph(
    data = make_org(),
    team = "Health"
  )
  
  expect_error(
    organoR:::make_dot(
      parts = parts,
      theme = theme_scotgov(),
      shaded_profession = character()
    ),
    "`shaded_profession` must be NULL"
  )
  
  expect_error(
    organoR:::make_dot(
      parts = parts,
      theme = theme_scotgov(),
      shaded_profession = c(
        "OR",
        "Statistician"
      )
    ),
    "`shaded_profession` must be NULL"
  )
  
  expect_error(
    organoR:::make_dot(
      parts = parts,
      theme = theme_scotgov(),
      shaded_profession = ""
    ),
    "`shaded_profession` must be NULL"
  )
  
  expect_error(
    organoR:::make_dot(
      parts = parts,
      theme = theme_scotgov(),
      shaded_profession = NA_character_
    ),
    "`shaded_profession` must be NULL"
  )
})
