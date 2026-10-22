# Declare symbols used by tidy evaluation and igraph expressions.
#
# This file prevents R CMD check from treating data-mask pronouns and
# graph attributes as undefined global variables.

utils::globalVariables(
  c(
    ".data",
    "node_id"
  )
)