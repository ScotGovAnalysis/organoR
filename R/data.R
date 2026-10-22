#' Simple organisational structure
#'
#' A small example dataset containing a single team and a straightforward
#' line-management hierarchy.
#'
#' @format A tibble with 3 rows and 6 variables:
#' \describe{
#'   \item{name}{Employee name, or `"Vacancy"` for an unoccupied position.}
#'   \item{grade}{Organisational grade.}
#'   \item{profession}{Employee or position profession.}
#'   \item{team}{Team to which the employee or position belongs.}
#'   \item{manager}{Name of the manager; `NA` identifies a root position.}
#'   \item{manager_type}{Management relationship: `"line"` or `"dotted"`.}
#' }
#' @source `inst/extdata/simple_org.csv`
"simple_org"

#' Matrix-management organisational structure
#'
#' An example dataset containing line and dotted management relationships,
#' including a manager from another team.
#'
#' @format A tibble with 4 rows and 6 variables:
#' \describe{
#'   \item{name}{Employee name, or `"Vacancy"` for an unoccupied position.}
#'   \item{grade}{Organisational grade.}
#'   \item{profession}{Employee or position profession.}
#'   \item{team}{Team to which the employee or position belongs.}
#'   \item{manager}{Name of the manager; `NA` identifies a root position.}
#'   \item{manager_type}{Management relationship: `"line"` or `"dotted"`.}
#' }
#' @source `inst/extdata/matrix_org.csv`
"matrix_org"

#' Organisational structure containing vacancies
#'
#' An example dataset containing occupied positions and multiple vacancies.
#' Each vacancy receives a unique identifier when passed to [build_graph()].
#'
#' @format A tibble with 4 rows and 6 variables:
#' \describe{
#'   \item{name}{Employee name, or `"Vacancy"` for an unoccupied position.}
#'   \item{grade}{Organisational grade.}
#'   \item{profession}{Employee or position profession.}
#'   \item{team}{Team to which the employee or position belongs.}
#'   \item{manager}{Name of the manager; `NA` identifies a root position.}
#'   \item{manager_type}{Management relationship: `"line"` or `"dotted"`.}
#' }
#' @source `inst/extdata/vacancy_org.csv`
"vacancy_org"

#' Complex multi-team organisational structure
#'
#' A larger example dataset containing multiple teams, professions, vacancies,
#' cross-team managers, and line and dotted management relationships. It is
#' suitable for demonstrating profession-specific shading and multi-team HTML
#' output.
#'
#' @format A tibble with 14 rows and 6 variables:
#' \describe{
#'   \item{name}{Employee name, or `"Vacancy"` for an unoccupied position.}
#'   \item{grade}{Organisational grade.}
#'   \item{profession}{Employee or position profession.}
#'   \item{team}{Team to which the employee or position belongs.}
#'   \item{manager}{Name of the manager; `NA` identifies a root position.}
#'   \item{manager_type}{Management relationship: `"line"` or `"dotted"`.}
#' }
#' @source `inst/extdata/complex_org.csv`
"complex_org"
