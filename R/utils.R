.required_columns <- c("name", "grade", "profession", "team", "manager", "manager_type")
.valid_grades <- c("B1", "B2", "B3", "C1", "C2", "C3")
.valid_professions <- c("OR", "Statistician", "Economist", "Social Researcher")
.valid_manager_types <- c("line", "dotted")
.grade_order <- c("C3", "C2", "C1", "B3", "B2", "B1")

abort_org <- function(message) cli::cli_abort(message, class = "organoR_validation_error")
warn_org <- function(message) cli::cli_warn(message, class = "organoR_validation_warning")

dot_quote <- function(x) {
  x <- ifelse(
    is.na(x),
    "",
    as.character(x)
  )
  
  encodeString(
    x,
    quote = "\"",
    na.encode = FALSE
  )
}

make_identity <- function(name, grade, profession, team) {
  paste(name, grade, profession, team, sep = "\r")
}
