#!/usr/bin/env Rscript
# Utility script to visualize semPlot .lvd model files.
# Usage: Rscript src/r/load_lvd.R path/to/model1.lvd [path/to/model2.lvd ...]

suppressPackageStartupMessages({
  if (!requireNamespace("semPlot", quietly = TRUE)) {
    stop("Package 'semPlot' is required. Install it with install.packages(\"semPlot\").")
  }
  if (!requireNamespace("MplusAutomation", quietly = TRUE)) {
    stop("Package 'MplusAutomation' is required for parsing .lvd files. Install it with install.packages(\"MplusAutomation\").")
  }
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide one or more .lvd files. Example: Rscript src/r/load_lvd.R ~/Downloads/model.lvd")
}

out_dir <- file.path("results", "lvd_plots")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

extract_model_source <- function(input_path) {
  ext <- tolower(tools::file_ext(input_path))
  if (ext != "lvd") {
    return(list(path = input_path, cleanup = NULL))
  }

  tmp_dir <- tempfile(pattern = "lvd_extract_")
  dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
  utils::unzip(input_path, exdir = tmp_dir)
  lvm_candidates <- list.files(tmp_dir, pattern = "\\.lvm$", full.names = TRUE)
  if (length(lvm_candidates) == 0) {
    stop("No .lvm file found inside ", input_path)
  }
  list(path = lvm_candidates[[1]], cleanup = tmp_dir)
}

cleanup_dirs <- character()

for (lvd_path in args) {
  if (!file.exists(lvd_path)) {
    warning("File not found: ", lvd_path)
    next
  }
  message("Loading ", lvd_path)
  model_source <- extract_model_source(lvd_path)
  if (!is.null(model_source$cleanup)) {
    cleanup_dirs <- c(cleanup_dirs, model_source$cleanup)
  }
  model <- semPlot::semPlotModel(model_source$path)
  base_name <- tools::file_path_sans_ext(basename(lvd_path))
  png_path <- file.path(out_dir, paste0(base_name, "_semPaths.png"))
  png(png_path, width = 1600, height = 1200)
  semPlot::semPaths(
    model,
    whatLabels = "std",
    layout = "tree",
    residuals = TRUE,
    nCharNodes = 0,
    edge.label.cex = 0.9
  )
  dev.off()
  message("Saved standardized path diagram to ", png_path)
}

message("Done. Check ", out_dir, " for generated PNGs.")

if (length(cleanup_dirs)) {
  unlink(cleanup_dirs, recursive = TRUE, force = TRUE)
}
