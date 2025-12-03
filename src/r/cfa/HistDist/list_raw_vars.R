suppressPackageStartupMessages({
  ok <- requireNamespace("haven", quietly = TRUE)
  if (!ok) ok <- requireNamespace("foreign", quietly = TRUE)
})

raw_path <- file.path("data", "raw", "2025_ED_852_HERI_data.sav")
out_dir <- file.path("results", "cfa")
if (!file.exists(raw_path)) stop("Raw SPSS file not found at ", raw_path)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (requireNamespace("haven", quietly = TRUE)) {
  library(haven)
  df <- read_sav(raw_path)
  # try to get variable labels
  labels <- sapply(df, function(x) attr(x, "label"))
} else {
  library(foreign)
  df <- read.spss(raw_path, to.data.frame = TRUE, use.value.labels = FALSE)
  labels <- sapply(df, function(x) attr(x, "variable.label"))
}

vars <- data.frame(name = names(df), label = as.character(labels), stringsAsFactors = FALSE)
write.csv(vars, file = file.path(out_dir, "raw_var_labels.csv"), row.names = FALSE)
cat("Wrote variable list to", file.path(out_dir, "raw_var_labels.csv"), "\n")
