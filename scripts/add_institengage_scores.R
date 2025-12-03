# Script to fit Institutional Engagement CFA, compute factor scores,
# and append them to data/clean/OfficialDataset_Final.csv (overwrites file).

library(lavaan)

file <- "data/clean/OfficialDataset_Final.csv"
backup_file <- paste0(sub("\\.csv$", "", file),
                      "_backup_before_institengage_",
                      format(Sys.time(), "%Y%m%d_%H%M%S"),
                      ".csv")

if (!file.exists(file)) stop("Official dataset not found: ", file)
file.copy(file, backup_file, overwrite = TRUE)
cat("Backup written to:", backup_file, "\n")

# read official dataset
dat <- read.csv(file, stringsAsFactors = FALSE, check.names = FALSE)

# model for Institutional Engagement
inst_model <- '\n  InstitEngage =~ SATIS07 + SATIS25 + SATIS13 + SATIS15 + SATIS01\n'

# fit CFA
fit_inst <- cfa(inst_model, data = dat)

# print summary
print(summary(fit_inst, fit.measures = TRUE, standardized = TRUE))

# predict factor scores and attach
inst_scores <- lavPredict(fit_inst)
inst_scores_df <- as.data.frame(inst_scores)
# name column if not named
if (ncol(inst_scores_df) >= 1) names(inst_scores_df)[1] <- "InstitEngage_fs"

# safety check
if (nrow(inst_scores_df) != nrow(dat)) stop("Row counts differ between scores and data")

# add/replace column
dat$InstitEngage_fs <- inst_scores_df$InstitEngage_fs

# overwrite original file
write.csv(dat, file, row.names = FALSE)
cat("Wrote updated file:", file, "\n")
