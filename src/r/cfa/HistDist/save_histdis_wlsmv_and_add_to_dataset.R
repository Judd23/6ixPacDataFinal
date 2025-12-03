# Fit HistDisadv with WLSMV, save outputs, and add factor scores to dataset
suppressPackageStartupMessages({
  library(lavaan)
  library(dplyr)
})

data_path <- file.path("data", "clean", "OfficialDataset_Final.csv")
out_dir <- file.path("results", "cfa")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(data_path)) stop("Missing clean dataset at ", data_path)

orig <- read.csv(data_path)

inds <- c("FirstGen_RC", "UndrRepStud_RC", "FINCON_RC", "INCOME", "CITIZEN")
inds_present <- inds[inds %in% names(orig)]
if (length(inds_present) < 3) stop('Need at least 3 indicators present in the dataset; found: ', paste(inds_present, collapse = ", "))

# Prepare ordered indicators for WLSMV
data_ord <- orig
for (v in inds_present) {
  data_ord[[v]] <- ifelse(is.na(data_ord[[v]]), NA, as.integer(data_ord[[v]]))
  data_ord[[v]] <- ordered(data_ord[[v]])
}

model <- '\nHistDisadv =~ FirstGen_RC + UndrRepStud_RC + FINCON_RC + INCOME + CITIZEN\n'

# Fit with WLSMV (categorical)
fit <- tryCatch({
  lavaan::cfa(model, data = data_ord, ordered = inds_present, estimator = "WLSMV", missing = "pairwise")
}, error = function(e) {
  message('WLSMV failed: ', e$message, '\nFalling back to ML with FIML on numeric data')
  lavaan::lavaan(model, data = orig, meanstructure = TRUE, estimator = "ML", missing = "fiml")
})

# Save fit object
saveRDS(fit, file = file.path(out_dir, "histdis_wlsmv_fit.rds"))

# Parameter estimates
pe <- parameterEstimates(fit, standardized = TRUE)
write.csv(pe, file = file.path(out_dir, "histdis_wlsmv_parameters_full.csv"), row.names = FALSE)

# Loadings only
loadings <- subset(pe, op == "=~")
write.csv(loadings, file = file.path(out_dir, "histdis_wlsmv_loadings.csv"), row.names = FALSE)

# R-squared
r2 <- inspect(fit, "r2")
r2_df <- data.frame(indicator = names(r2), r2 = as.numeric(r2), row.names = NULL)
write.csv(r2_df, file = file.path(out_dir, "histdis_wlsmv_r2.csv"), row.names = FALSE)

# Fit measures (key indices)
fm <- fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))
fm_df <- data.frame(measure = names(fm), value = as.numeric(fm), row.names = NULL)
write.csv(fm_df, file = file.path(out_dir, "histdis_wlsmv_fit_measures.csv"), row.names = FALSE)

# Factor scores (regression). For categorical models, lavPredict works.
fs_raw <- tryCatch(lavPredict(fit, method = "regression"), error = function(e) {
  message('lavPredict failed: ', e$message)
  return(rep(NA, nrow(orig)))
})

# Extract latent score vector (latent name 'HistDisadv')
if (is.matrix(fs_raw) || is.data.frame(fs_raw)) {
  if ("HistDisadv" %in% colnames(fs_raw)) scores <- as.numeric(fs_raw[, "HistDisadv"]) else scores <- as.numeric(fs_raw[,1])
} else {
  scores <- as.numeric(fs_raw)
}

# Save scores to results
scores_df <- data.frame(HistDisadv = scores)
write.csv(scores_df, file = file.path(out_dir, "histdis_wlsmv_scores.csv"), row.names = FALSE)

# Backup original dataset and add HistDisadv column
ts <- format(Sys.time(), "%Y%m%d_%H%M%S")
backup_path <- file.path("data", "clean", paste0("OfficialDataset_Final_backup_before_histdis_wlsmv_", ts, ".csv"))
file.copy(data_path, backup_path, overwrite = TRUE)

# Add column to original dataset (do not overwrite existing HistDisadv if present)
orig2 <- orig
if ("HistDisadv" %in% names(orig2)) {
  # preserve existing, add new column with suffix
  newcol <- paste0("HistDisadv_wlsmv_", ts)
  orig2[[newcol]] <- scores
} else {
  orig2$HistDisadv <- scores
}

# Write updated dataset back and an alternate copy
write.csv(orig2, file = data_path, row.names = FALSE)
write.csv(orig2, file = file.path("data", "clean", paste0("OfficialDataset_Final_with_histdis_wlsmv_", ts, ".csv")), row.names = FALSE)

cat('Saved WLSMV fit and parameter tables to', normalizePath(out_dir), '\n')
cat('Backup of original dataset:', normalizePath(backup_path), '\n')
cat('Updated dataset written to:', normalizePath(data_path), '\n')
cat('Scores CSV:', normalizePath(file.path(out_dir, "histdis_wlsmv_scores.csv")), '\n')
