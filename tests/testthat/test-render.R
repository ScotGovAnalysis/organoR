test_that("DOT applies clarified styling rules", {
  x <- dplyr::bind_rows(make_org(), tibble::tibble(name="Vacancy", grade="B3", profession="OR", team="Health", manager="Lead", manager_type="line"))
  dot <- organoR:::make_dot(get_team_subgraph(x, "Health"), theme_scotgov())
  expect_match(dot, 'style="dotted"')
  expect_match(dot, '#FFF2CC')
  expect_match(dot, 'rank=same')
  expect_match(dot, 'C2\\nStatistician')
  expect_false(grepl('Lead\\nC2\\nStatistician', dot))
})
