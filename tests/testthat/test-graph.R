test_that("multiple managers retain one employee and two edges", {
  b <- build_graph(make_org())
  expect_equal(sum(b$nodes$name == "Analyst"), 1)
  analyst <- b$nodes$node_id[b$nodes$name == "Analyst"]
  expect_equal(sum(b$edges$to == analyst), 2)
  expect_true(igraph::is_dag(b$graph))
  expect_true(all(grepl("^employee_", stats::na.omit(b$nodes$employee_id))))
})

test_that("vacancies receive unique IDs", {
  x <- read_org_data(system.file("extdata", "vacancy_org.csv", package="organoR"))
  b <- build_graph(x)
  expect_equal(length(unique(stats::na.omit(b$nodes$vacancy_id))), 2)
})
