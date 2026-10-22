test_that("cross-team recursive ancestors are included", {
  s <- get_team_subgraph(make_org(), "Health")
  expect_true(all(c("Director", "Lead", "Analyst") %in% s$nodes$name))
  expect_true("Justice" %in% s$nodes$team)
})
