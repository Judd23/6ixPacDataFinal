#!/usr/bin/env Rscript
# Comprehensive CFA report script (WLSMV, ordered indicators, SATIS28 anchored)
# Usage: Rscript src/r/cfa/cfa_success_report.R "/path/to/data.sav"

suppressPackageStartupMessages({
  library(lavaan)
  have_semTools <- requireNamespace("semTools", quietly = TRUE)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript src/r/cfa/cfa_success_report.R <data_path>")
}
data_path <- args[1]
if (!file.exists(data_path)) stop("Data file not found: ", data_path)

read_data <- function(path) {
  if (grepl("\\.sav$", path, ignore.case = TRUE)) {
    if (!requireNamespace("haven", quietly = TRUE)) {
      stop("Need package 'haven' to read .sav files. Install via install.packages('haven').")
    }
    return(as.data.frame(haven::read_sav(path)))
  }
  utils::read.csv(path, stringsAsFactors = FALSE)
}

df <- read_data(data_path)

indicators <- c("SATIS28", "SUCCESS4", "SUCCESS7", "SLFCHG09", "SLFCHG02")
missing_vars <- setdiff(indicators, names(df))
if (length(missing_vars)) stop("Missing variables in dataset: ", paste(missing_vars, collapse = ", "))

# convert to ordered factors for WLSMV
convert_ordered <- function(x) {
  if (inherits(x, "labelled")) {
    if (requireNamespace("haven", quietly = TRUE)) {
      x <- haven::zap_labels(x)
    } else {
      x <- as.vector(x)
    }
  }
  if (is.ordered(x)) return(x)
  if (is.factor(x)) return(ordered(x))
  if (is.character(x)) return(ordered(as.factor(x)))
  ordered(as.factor(x))
}

df[indicators] <- lapply(df[indicators], convert_ordered)

model <- 'SUCCESS =~ 1*SATIS28 + SUCCESS4 + SUCCESS7 + SLFCHG09 + SLFCHG02'

cat("\n=== Fitting CFA (WLSMV, ordered indicators) ===\n")
fit <- cfa(model, data = df, estimator = "WLSMV", ordered = indicators)

cat("\n--- Model Summary ---\n")
print(summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))

cat("\n--- Fit Measures (key indices) ---\n")
print(fitMeasures(fit, c("chisq","df","pvalue","cfi","tli","rmsea","rmsea.ci.lower","rmsea.ci.upper","srmr")))

cat("\n--- Parameter Estimates (with standardized loadings) ---\n")
pe <- parameterEstimates(fit, standardized = TRUE)
loadings <- subset(pe, op == "=~", select = c(lhs, rhs, est, se, z, pvalue, std.all))
print(loadings)

cat("\n--- Residual Variances ---\n")
resid_vars <- subset(pe, op == "~~" & lhs %in% indicators & lhs == rhs, select = c(lhs, est, se, z, pvalue))
print(resid_vars)

cat("\n--- R-squared ---\n")
print(inspect(fit, "r2"))

if (have_semTools) {
  cat("\n--- Reliability (semTools::reliability) ---\n")
  print(semTools::reliability(fit))
  cat("\n--- Average Variance Extracted (semTools::AVE) ---\n")
  print(semTools::AVE(fit))
} else {
  cat("\n(Note: Install 'semTools' for reliability/AVE calculations.)\n")
}

cat("\n=== End of CFA report ===\n")
