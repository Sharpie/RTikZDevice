.First.lib <-
function(libname, pkgname) {
  library.dynam("pgfDevice", pkgname, libname)
}
