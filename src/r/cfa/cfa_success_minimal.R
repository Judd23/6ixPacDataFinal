#!/usr/bin/env Rscript
# Minimal CFA runner for SUCCESS (ordinal indicators)
suppressPackageStartupMessages({
  if(!requireNamespace("lavaan", quietly=TRUE)) install.packages("lavaan", repos="https://cloud.r-project.org")
  if(!requireNamespace("readr", quietly=TRUE)) install.packages("readr", repos="https://cloud.r-project.org")
  library(readr); library(lavaan)
})
data_path <- "data/interim/df_subset.csv"
if(!file.exists(data_path)) stop("Data not found: ", data_path)
df <- readr::read_csv(data_path, show_col_types = FALSE)
vars <- c("COLLGPA","SATIS28","SATIS13","SLFCHG02")
if(!all(vars %in% names(df))) stop("Missing variables: ", paste(setdiff(vars, names(df)), collapse=", "))
# convert to ordered factors if likely Likert (<=10 uniques)
df[vars] <- lapply(df[vars], function(x){
  if((is.numeric(x) || is.integer(x)) && length(unique(na.omit(x))) <= 10) return(ordered(as.factor(x)))
  if(is.character(x)) return(ordered(as.factor(x)))
  return(x)
})
model <- 'SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02'
cat("Fitting WLSMV CFA (ordinal)\n")
fit <- lavaan::cfa(model, data = df, ordered = vars, estimator = "WLSMV", missing = "listwise")
print(summary(fit, fit.measures=TRUE, standardized=TRUE))
# save small outputs
dir.create("results", showWarnings = FALSE)
write.csv(as.data.frame(lavaan::standardizedSolution(fit)), file="results/cfa_success_standardized_loadings.csv", row.names = FALSE)
fit_meas <- as.data.frame(t(lavaan::fitMeasures(fit)))
write.csv(fit_meas, file="results/cfa_success_fit_measures.csv", row.names = TRUE)
cat("Done. Results written to results/\n")
