.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste(
    "org",
    utils::packageDescription("org")$Version,
    "https://folkehelseinstituttet.github.io/org"
  ))
}
