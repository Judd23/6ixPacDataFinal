#!/usr/bin/env Rscript
# CFA from a specified SPSS .sav file (safe checks + WLSMV for ordinal indicators)
suppressPackageStartupMessages({
  # install if missing
  pkgs <- c("haven","lavaan","semTools","psych","readr")
  missing <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
  if(length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
  library(haven); library(lavaan); library(semTools); library(psych); library(readr)
})

args <- commandArgs(trailingOnly = TRUE)
sav_path <- ifelse(length(args) >= 1, args[1], "/Users/jjohnson3/StatsFullData.sav")
out_dir <- "results"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

if(!file.exists(sav_path)) stop("SPSS file not found: ", sav_path)
cat("Reading:", sav_path, "\n")
d <- try(read_sav(sav_path), silent = TRUE)
if(inherits(d, "try-error")) stop("Could not read SAV file: ", sav_path)

cat("Variables in SAV (first 200 chars):\n")
cat(paste(names(d), collapse = ", "), "\n\n")

# Indicators you want for SUCCESS:
requested <- c("COLLGPA","SATIS28","SATIS13","SLFCHG02")

missing_vars <- setdiff(requested, names(d))
if(length(missing_vars) > 0) {
  cat("Warning: these requested variables were NOT found in the SAV file:\n")
  cat(paste(missing_vars, collapse = ", "), "\n\n")
  cat("Please inspect the variable names above and re-run providing the correct names.\n")
  stop("Missing variables: ", paste(missing_vars, collapse = ", "))
}

# If found, subset and coerce
df <- as.data.frame(d)
indicators <- requested
# convert likely ordinal variables to ordered factor (heuristic)
for(v in indicators) {
  x <- df[[v]]
  if (!is.ordered(x)) {
    if ((is.numeric(x) || is.integer(x)) && length(unique(na.omit(x))) <= 10) {
      df[[v]] <- ordered(as.factor(x))
    } else if (is.character(x)) {
      df[[v]] <- ordered(as.factor(x))
    }
  }
}

# Model
cfa_model <- 'SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02'
cat("Fitting CFA (WLSMV) on ordered indicators...\n")
fit <- try(cfa(cfa_model, data = df, ordered = indicators, estimator = "WLSMV", missing = "listwise"), silent = TRUE)
if(inherits(fit, "try-error")) stop("lavaan fit failed: ", fit)

# Save outputs
sink(file.path(out_dir, "cfa_success_from_sav_summary.txt"))
print(summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))
sink()

fit_measures <- fitMeasures(fit, c("chisq","df","pvalue","cfi","tli","rmsea","srmr"))
write.csv(as.data.frame(t(fit_measures)), file = file.path(out_dir, "cfa_success_from_sav_fit_measures.csv"), row.names = TRUE)

std_sol <- standardizedSolution(fit)
write.csv(as.data.frame(std_sol), file = file.path(out_dir, "cfa_success_from_sav_standardized_solution.csv"), row.names = FALSE)

# reliability & factor scores
alpha_res <- try(psych::alpha(df[indicators] %>% mutate(across(everything(), ~ as.numeric(as.character(.)))), na.rm = TRUE), silent = TRUE)
if (!inherits(alpha_res, "try-error")) capture.output(alpha_res, file = file.path(out_dir, "cfa_success_from_sav_alpha.txt"))

fs <- try(lavPredict(fit), silent = TRUE)
if(!inherits(fs, "try-error")) {
  out_scores <- data.frame(SUCCESS_factor = as.numeric(fs))
  write.csv(out_scores, file = file.path(out_dir, "cfa_success_from_sav_factor_scores.csv"), row.names = FALSE)
}

cat("CFA finished. Results written to", out_dir, "\n")
