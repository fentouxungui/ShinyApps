# Build the ShinyApps suite (root of the ShinyApps repo).
# Runs locally (Rscript build-suite.R) and in GitHub Actions.
#
# Prep (must exist before running):
#   dependency/SeuratExplorer_<v>.tar.gz
#   dependency/presto-1.1.0.tar.gz
#   dependency/scConvertShiny_<v>.tar.gz
#   dependency/scConvert_<v>.tar.gz
#   icons/seurat-explorer.png, icons/scconvert.png
#   _shinyelectron.yml, apps/seurat-explorer/app.R, apps/scconvert/app.R

library(shinyelectron)

ws <- Sys.getenv("GITHUB_WORKSPACE", unset = getwd())
setwd(ws)
options(timeout = 3600)   # bundled installs pull a lot of packages; be patient

# ---- HDF5 for scConvert's configure step (macOS) ---------------------- 
# scConvert compiles from source inside the bundled R runtime; its configure
# needs HDF5. Provide it explicitly (mirrors the working scConvertShiny script).
if (identical(tolower(Sys.info()[["sysname"]]), "darwin")) {
  system("brew install hdf5 pkg-config")            # idempotent
  h5 <- tryCatch(system("brew --prefix hdf5", intern = TRUE), error = function(e) character(0))
  if (length(h5) == 1 && dir.exists(h5)) {
    Sys.setenv(
      PKG_CONFIG_PATH = file.path(h5, "lib", "pkgconfig"),
      HDF5_CFLAGS     = paste0("-I", file.path(h5, "include")),
      HDF5_LIBS       = paste0("-L", file.path(h5, "lib"), " -lhdf5")
    )
    message("HDF5 from Homebrew: ", h5)
  } else {
    warning("Homebrew hdf5 not found; scConvert may fail to configure.")
  }
}

# ---- Build ------------------------------------------------------------
export(
  appdir    = ws,                    # suite root; find_config() reads _shinyelectron.yml here
  destdir   = file.path(ws, "build"),
  app_name  = "ShinyApps",
  icon      = NULL,                  # per-app icons come from apps[].icon
  run_after = FALSE,
  overwrite = TRUE
)
