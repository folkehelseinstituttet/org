#' Folders to be used/referenced (depreciated)
#' @export PROJ
PROJ <- new.env(parent = emptyenv())

#' Folders to be used/referenced
#' @export project
project <- new.env()

# Config
CONFIG <- new.env(parent = emptyenv())
CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT <- FALSE
CONFIG$rstudio <- FALSE

utils::globalVariables("debugSource")
