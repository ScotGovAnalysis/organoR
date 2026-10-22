test_that("schema and values are validated", {
  x <- make_org()
  expect_error(validate_org_data(x[, -1]), "Missing")
  expect_error(validate_org_data(dplyr::mutate(x, grade = "A1")), "Invalid grades")
  expect_error(validate_org_data(dplyr::mutate(x, manager_type = "other")), "Invalid manager")
  expect_error(validate_org_data(dplyr::mutate(x, manager = dplyr::if_else(name == "Analyst", "Missing", manager))), "not found")
})

test_that("metadata conflicts and cycles fail", {
  x <- dplyr::bind_rows(make_org(), tibble::tibble(name="Lead", grade="C1", profession="Statistician", team="Health", manager=NA_character_, manager_type="line"))
  expect_error(validate_org_data(x), "Inconsistent")
  y <- make_org(); y$manager[y$name == "Director"] <- "Analyst"
  expect_error(validate_org_data(y), "Circular")
})
