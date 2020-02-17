.onLoad <- function(libname, pkgname) {
  if(base::requireNamespace("rstudioapi", quietly = TRUE)){
    CONFIG$rstudio <- rstudioapi::isAvailable()
  } else if(interactive() & Sys.getenv("RSTUDIO")==1){
    warning("Install 'rstudioapi' package to enable breakpoint debugging")
  }

  invisible()
}
