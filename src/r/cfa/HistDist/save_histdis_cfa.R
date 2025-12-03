# Script to fit the Historically Disadvantaged CFA and save results
suppressPackageStartupMessages({
  library(lavaan)
  library(semTools)
  library(psych)
  library(GPArotation)
  library(dplyr)
})

# paths
data_path <- file.path("data", "clean", "OfficialDataset_Final.csv")
out_dir <- file.path("results", "cfa")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(data_path)) stop("Missing clean dataset at ", data_path)

data <- read.csv(data_path)

model <- '\n# measurement model\n HistDisadv =~ FirstGen_RC + UndrRepStud_RC + \n                   FINCON_RC\n\n# (residual) (co)variances\n HistDisadv ~~ HistDisadv'

fit <- lavaan::lavaan(model, data = data, meanstructure = "default",
                     int.ov.free = TRUE, int.lv.free = FALSE,
                     estimator = "default", se = "default",
                     missing = "fiml", auto.fix.first = TRUE,
                     auto.fix.single = TRUE, auto.var = TRUE,
                     auto.cov.lv.x = TRUE, auto.cov.y = TRUE,
                     fixed.x = TRUE, auto.th = TRUE,
                     auto.delta = TRUE)

# Save lavaan object
saveRDS(fit, file = file.path(out_dir, "histdis_fit.rds"))

# Full parameter estimates
pe <- parameterEstimates(fit, standardized = TRUE)
write.csv(pe, file = file.path(out_dir, "histdis_parameters_full.csv"), row.names = FALSE)

# Loadings only
loadings <- subset(pe, op == "=~")
write.csv(loadings, file = file.path(out_dir, "histdis_loadings.csv"), row.names = FALSE)

# R-squared
r2 <- inspect(fit, "r2")
r2_df <- data.frame(indicator = names(r2), r2 = as.numeric(r2), row.names = NULL)
write.csv(r2_df, file = file.path(out_dir, "histdis_r2.csv"), row.names = FALSE)

# Key fit measures
fm <- fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))
fm_df <- data.frame(measure = names(fm), value = as.numeric(fm), row.names = NULL)
write.csv(fm_df, file = file.path(out_dir, "histdis_fit_measures.csv"), row.names = FALSE)

# Reliability & AVE if available
if (requireNamespace("semTools", quietly = TRUE)) {
  rel <- tryCatch(semTools::compRelSEM(fit), error = function(e) NULL)
  if (!is.null(rel)) {
    # write the output if it's a list/data structure
    try(write.csv(as.data.frame(rel), file = file.path(out_dir, "histdis_reliability.csv"), row.names = FALSE), silent = TRUE)
  } else {
    # fallback to deprecated reliability and AVE
    rel_old <- tryCatch(semTools::reliability(fit), error = function(e) NULL)
    if (!is.null(rel_old)) {
      write.csv(as.data.frame(rel_old), file = file.path(out_dir, "histdis_reliability.csv"), row.names = FALSE)
    }
    ave <- tryCatch(semTools::AVE(fit), error = function(e) NULL)
    if (!is.null(ave)) {
      ave_df <- data.frame(latent = names(ave), ave = as.numeric(ave), row.names = NULL)
      write.csv(ave_df, file = file.path(out_dir, "histdis_ave.csv"), row.names = FALSE)
    }
  }
}

cat("Saved lavaan object and CSV outputs to:", normalizePath(out_dir), "\n")
