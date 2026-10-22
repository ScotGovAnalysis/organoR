# Create package datasets from CSV source files in inst/extdata.
#
# Output files produced:
#   data/simple_org.rda
#   data/matrix_org.rda
#   data/vacancy_org.rda
#   data/complex_org.rda
#
# Run this script from the package root after changing any source CSV file.

source_files <- c(
  simple_org = "simple_org.csv",
  matrix_org = "matrix_org.csv",
  vacancy_org = "vacancy_org.csv",
  complex_org = "complex_org.csv"
)

read_source_data <- function(file_name) {
  readr::read_csv(
    file = file.path("inst", "extdata", file_name),
    na = c("", "NA"),
    show_col_types = FALSE
  ) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(
          c(
            "name",
            "grade",
            "profession",
            "team",
            "manager",
            "manager_type"
          )
        ),
        as.character
      )
    )
}

dir.create(
  "data",
  recursive = TRUE,
  showWarnings = FALSE
)

purrr::iwalk(
  source_files,
  function(file_name, object_name) {
    package_data <- read_source_data(file_name)

    assign(
      x = object_name,
      value = package_data,
      envir = environment()
    )

    save(
      list = object_name,
      file = file.path("data", paste0(object_name, ".rda")),
      envir = environment(),
      compress = "xz",
      version = 3
    )
  }
)
