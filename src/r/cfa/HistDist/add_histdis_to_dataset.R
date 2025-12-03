# Add Historically Disadvantaged latent factor scores to the clean dataset
suppressPackageStartupMessages({
  library(lavaan)
  library(dplyr)
})

fit_path <- file.path("results", "cfa", "histdis_fit.rds")
data_path <- file.path("data", "clean", "OfficialDataset_Final.csv")
backup_path <- file.path("data", "clean", "OfficialDataset_Final_backup_before_histdis.csv")
out_dir <- file.path("results", "cfa")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(fit_path)) stop("Saved lavaan fit not found at ", fit_path)
if (!file.exists(data_path)) stop("Clean dataset not found at ", data_path)

fit <- readRDS(fit_path)

# read original data
orig <- read.csv(data_path)

# compute factor scores (regression)
scores_mat <- tryCatch(lavPredict(fit, method = "regression"), error = function(e) lavPredict(fit))

# if single factor, ensure it's a vector
if (is.matrix(scores_mat) || is.data.frame(scores_mat)) {
  if (ncol(scores_mat) == 1) {
    scores <- as.numeric(scores_mat[,1])
    names(scores) <- NULL
  } else if ("HistDisadv" %in% colnames(scores_mat)) {
    scores <- as.numeric(scores_mat[, "HistDisadv"]) 
  } else {
    # take first column as fallback
    scores <- as.numeric(scores_mat[,1])
  }
} else {
  scores <- as.numeric(scores_mat)
}

# prepare scores dataframe
scores_df <- data.frame(HistDisadv_score = scores)

# attach scores to the original data (assumes same ordering)
if (nrow(orig) != nrow(scores_df)) stop("Row count mismatch between dataset and factor scores")

orig2 <- bind_cols(orig, scores_df)

# backup original file
file.copy(data_path, backup_path, overwrite = TRUE)

# write updated dataset back to the original path and also a separate file
write.csv(orig2, file = data_path, row.names = FALSE)
write.csv(orig2, file = file.path("data", "clean", "OfficialDataset_Final_with_histdis.csv"), row.names = FALSE)

# also save just the scores to results
write.csv(scores_df, file = file.path(out_dir, "histdis_scores.csv"), row.names = FALSE)

cat("Added 'HistDisadv_score' to dataset and saved updated files:\n")
cat(" - Backup of original: ", normalizePath(backup_path), "\n")
cat(" - Updated dataset: ", normalizePath(data_path), "\n")
cat(" - Alternative updated file: ", normalizePath(file.path("data", "clean", "OfficialDataset_Final_with_histdis.csv")), "\n")
cat(" - Scores CSV: ", normalizePath(file.path(out_dir, "histdis_scores.csv")), "\n")
