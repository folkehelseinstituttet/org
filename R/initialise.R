SelectFolderThatExists <- function(folders, name){
  retval <- NA
  for(i in folders){
    if(dir.exists(i)){
      retval <- i
      break
    }
  }

  # if multiple folders are provided, then they *must* exist
  if(is.na(retval) & length(folders)>1){
    stop(sprintf("Multiple folders provided to %s, but none exist", name))
  } else if(is.na(retval) & length(folders)==1) retval <- folders

  return(retval)
}

#' Allows for InitialiseProject to manipulate files
#' on your system
#' @export AllowFileManipulationFromInitialiseProject
AllowFileManipulationFromInitialiseProject <- function(){
  CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT <- TRUE
}

#' Initialises project
#' @param HOME a
#' @param SHARED a
#' @param ... a
#' @export InitialiseProject
InitialiseProject <- function(HOME=NULL,
                              SHARED=NULL,
                              ...){

  PROJ$HOME <- HOME
  PROJ$SHARED <- SHARED

  arguments <- list(...)
  for(i in seq_along(arguments)){
    PROJ[[names(arguments)[i]]] <- arguments[[i]]
  }

  # If multiple files were provided, then select the folder that exists
  for(i in names(PROJ)){
    if(!is.null(PROJ[[i]])) PROJ[[i]] <- SelectFolderThatExists(PROJ[[i]], i)
  }

  # Add SHARED_TODAY to PROJ
  if(is.null(PROJ$SHARED)){
    PROJ$SHARED_TODAY <- NULL
  } else {
    PROJ$SHARED_TODAY <- file.path(PROJ$SHARED,lubridate::today())
  }

  if(!CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT){
    warning("You need to run 'org::AllowFileManipulationFromInitialiseProject()' for this function to create today's folder (org::PROJ$SHARED_TODAY)")
  } else {
    for(i in names(PROJ)){
      if(!is.null(PROJ[[i]])) if(!dir.exists(PROJ[[i]])) dir.create(PROJ[[i]], recursive=TRUE)
    }

    # Delete empty folders in shared folder
    if(!is.null(PROJ$SHARED)) for(f in list.files(PROJ$SHARED)){
      if(stringr::str_detect(f,"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")) if(f==lubridate::today()) next # don't want to delete today's folder
      f2 <- file.path(PROJ$SHARED,f)
      if(file.exists(f2) && !dir.exists(f2)) next # dont delete files
      if(length(list.files(f2))==0){
        unlink(f2, recursive = T)
      }
    }

    if(!is.null(PROJ$HOME)) if(!dir.exists(file.path(PROJ$HOME,"code"))) dir.create(file.path(PROJ$HOME,"code"))
  }

  if(!is.null(PROJ$HOME)){
    setwd(PROJ$HOME)

    fileSources = file.path("code",list.files("code",pattern="*.[rR]$"))
    sapply(fileSources,source,.GlobalEnv)
  }
}
