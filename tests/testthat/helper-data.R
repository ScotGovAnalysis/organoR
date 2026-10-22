make_org <- function() tibble::tribble(
  ~name, ~grade, ~profession, ~team, ~manager, ~manager_type,
  "Director", "C3", "OR", "Justice", NA, "line",
  "Lead", "C2", "Statistician", "Health", "Director", "line",
  "Analyst", "C1", "OR", "Health", "Lead", "line",
  "Analyst", "C1", "OR", "Health", "Director", "dotted"
)
