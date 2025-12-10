# Script to fit HistDisadv CFA, compute factor scores,
# and append them to data/clean/OfficialDataset_Final.csv (overwrites file).

# NOTE: This script assumes R (and lavaan) are installed and available in PATH.

library(lavaan)

file <- "data/clean/OfficialDataset_Final.csv"
backup_file <- paste0(sub("\\.csv$", "", file),
                      "_backup_before_histdis_",
                      format(Sys.time(), "%Y%m%d_%H%M%S"),
                      ".csv")

if (!file.exists(file)) stop("Official dataset not found: ", file)
file.copy(file, backup_file, overwrite = TRUE)
cat("Backup written to:", backup_file, "\n")

# read official dataset
dat <- read.csv(file, stringsAsFactors = FALSE, check.names = FALSE)

# define model and ordered vars
hist_model <- '\n  HistDisadv =~ FirstGen_RC + UndrRepStud_RC + FINCON_RC + INCOME + CITIZEN\n'
hist_vars  <- c("FirstGen_RC", "UndrRepStud_RC", "FINCON_RC", "INCOME", "CITIZEN")

# fit CFA (adjust estimator if needed)
fit_hist <- cfa(hist_model, data = dat, ordered = hist_vars)

# print summary
print(summary(fit_hist, fit.measures = TRUE, standardized = TRUE))

# predict factor scores and attach
hist_scores <- lavPredict(fit_hist)
hist_scores_df <- as.data.frame(hist_scores)
names(hist_scores_df)[1] <- "HistDisadv_fs"

# safety check
if (nrow(hist_scores_df) != nrow(dat)) stop("Row counts differ between scores and data")

# add column by row order (assuming same ordering)
dat$HistDisadv_fs <- hist_scores_df$HistDisadv_fs

# overwrite original file
write.csv(dat, file, row.names = FALSE)
cat("Wrote updated file:", file, "\n")
