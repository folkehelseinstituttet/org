strip_trailing_forwardslash <- function(x, encode_from, encode_to) {
  if (is.null(x)) {
    return(NULL)
  }
  retval <- sub("/$", "", x)

  if (requireNamespace("glue", quietly = TRUE)) {
    for (i in seq_along(retval)) retval[i] <- glue::glue(retval[i], .envir = parent.frame(n = 1))
  }
  if (.Platform$OS.type == "windows") {
    retval <- iconv(retval, from = encode_from, to = encode_to)
  }
  return(retval)
}

SelectFolderThatExists <- function(folders, name) {
  retval <- NA
  id <- NA
  for (i in seq_along(folders)) {
    if (dir.exists(folders[i])) {
      retval <- folders[i]
      id <- i
      break
    }
  }

  # if multiple folders are provided, then they *must* exist
  if (is.na(retval) & length(folders) > 1) {
    stop(sprintf("Multiple folders provided to %s, but none exist", name))
  } else if (is.na(retval) & length(folders) == 1) {
    retval <- folders
    id <- 1
  }

  return(list(
    folder = retval,
    id = id
  ))
}

#' Set results folder after initialization
#' @param results A folder inside `results` with today's date will be created and it will be accessible via `org::project$results_today` (this is where you will store all of your results)
#' @export
set_results <- function(results) {
  if (is.null(project[["computer_id"]])) stop("not initialized")
  project$results <- results[project[["computer_id"]]]

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  # Add SHARED_TODAY to project
  if (is.null(project$results)) {
    project$results_today <- NULL
  } else {
    project$results_today <- file.path(project$results, today)
  }

  if (!CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT) {
    warning("'initialize' needs to be run with 'create_folders' = TRUE")
  } else {
    for (i in names(project)) {
      if (i == "computer_id") next
      if (!is.null(project[[i]])) {
        if (!dir.exists(project[[i]])) dir.create(project[[i]], recursive = TRUE)
      }
    }

    # Delete empty folders in results folder
    if (!is.null(project$results)) {
      for (f in list.files(project$results)) {
        if (grepl("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]", f)) {
          if (f == today) next # don't want to delete today's folder
          f2 <- file.path(project$results, f)
          if (file.exists(f2) && !dir.exists(f2)) next # dont delete files
          if (length(list.files(f2)) == 0) {
            unlink(f2, recursive = T)
          }
        }
      }
    }
  }
}

# Allows for InitialiseProject to create folders and
# delete empty folders on your computer (depreciated)
allow_file_manip <- function() {
  CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT <- TRUE
}

#' Initializes project
#'
#' `org::initialize_project` takes in 2+ arguments.
#' It then saves its results (i.e. folder locations) in `org::project`,
#' which you will use in all of your subsequent code.
#'
#' You need to set `create_folders=TRUE`
#' for this function to create today's folder (org::project$results_today).
#'
#' For more details see the help vignette:
#' \code{vignette("intro", package = "org")}
#' @param home The folder containing 'Run.R' and 'R/'
#' @param results A folder inside `results` with today's date will be created and it will be accessible via `org::project$results_today` (this is where you will store all of your results)
#' @param folders_to_be_sourced The names of folders that live inside `home` and all .r and .R files inside it will be sourced into the global environment.
#' @param source_folders_absolute If `TRUE` then `folders_to_be_sourced` is an absolute folder reference. If `FALSE` then `folders_to_be_sourced` is relative and inside `home`.
#' @param create_folders Recommended that this is set to `TRUE`. It allows `org` to create any folders that are missing.
#' @param silent Silence all feedback
#' @param encode_from Folders current encoding (only used on Windows)
#' @param encode_to Folders final encoding (only used on Windows)
#' @param ... Other folders that you would like to reference
#' @examples
#' \dontrun{
#' org::initialize(
#'   home = "/git/analyses/2019/analysis3/",
#'   results = "/dropbox/analyses_results/2019/analysis3/",
#'   raw = "/data/analyses/2019/analysis3/"
#' )
#' org::project$results_today
#' org::project$raw
#' }
#' @export
initialize_project <- function(
                               home = NULL,
                               results = NULL,
                               folders_to_be_sourced = "R",
                               source_folders_absolute = FALSE,
                               create_folders = FALSE,
                               silent = FALSE,
                               encode_from = "UTF-8",
                               encode_to = "latin1",
                               ...) {
  if (create_folders) {
    allow_file_manip()
  } else if (!silent) {
    message("It is recommended to run with 'create_folders'=TRUE.\nThis message can be turned off with silent=TRUE")
  }

  project$home <- strip_trailing_forwardslash(home, encode_from = encode_from, encode_to = encode_to)
  project$results <- strip_trailing_forwardslash(results, encode_from = encode_from, encode_to = encode_to)

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  arguments <- list(...)
  for (i in seq_along(arguments)) {
    project[[names(arguments)[i]]] <- strip_trailing_forwardslash(arguments[[i]], encode_from = encode_from, encode_to = encode_to)
  }

  # If multiple files were provided, then select the folder that exists
  for (i in names(project)) {
    if (i == "computer_id") next
    if (!is.null(project[[i]])) {
      if (i == "home") {
        project[["computer_id"]] <- SelectFolderThatExists(project[[i]], i)[["id"]]
      }
      project[[i]] <- SelectFolderThatExists(project[[i]], i)[["folder"]]
    }
  }

  # Add results_today to path
  set_results(results = results)

  if (!is.null(project$home)) {
    setwd(project$home)

    for (i in folders_to_be_sourced) {
      if (source_folders_absolute) {
        folder <- i
      } else {
        folder <- file.path(project$home, i)
      }
      if (!dir.exists(folder)) {
        if (CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT) {
          warning(paste0("Folder ", folder, " does not exist. Creating it now."))
          dir.create(folder)
        } else {
          warning(paste0("Folder ", folder, " does not exist."))
        }
      } else {
        message(paste0("Sourcing all code inside ", folder, " into .GlobalEnv"))
        fileSources <- file.path(folder, list.files(folder, pattern = "*.[rR]$"))

        if (CONFIG$rstudio) {
          # rstudio
          print(fileSources)
          sapply(fileSources, debugSource)
        } else {
          sapply(fileSources, source, .GlobalEnv)
        }
      }
    }
  }
}
