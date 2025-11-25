#!/usr/bin/env Rscript
# src/r/cfa/cfa_success_full_fixed.R
# Upgraded CFA script for latent variable SUCCESS (ordinal indicators)
# This is a patched version that is more defensive around correlation outputs

## Load libraries (install if missing) -------------------------------------
pkg <- c("tidyverse", "lavaan", "semTools", "psych", "mice", "semPlot")
missing_pkgs <- pkg[!(pkg %in% installed.packages()[, "Package"])] 
if (length(missing_pkgs)) {
  message("Installing missing packages: ", paste(missing_pkgs, collapse = ", "))
  install.packages(missing_pkgs, repos = "https://cloud.r-project.org")
}
library(tidyverse)
library(lavaan)
library(semTools)
library(psych)
library(mice)
library(semPlot)

## Params & command-line override -----------------------------------------
args <- commandArgs(trailingOnly = TRUE)
data_path <- ifelse(length(args) >= 1, args[1], "data/interim/df_subset.csv")
out_dir <- "results"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

## Read data ---------------------------------------------------------------
if (!file.exists(data_path)) stop("Data file not found: ", data_path)
df <- read_csv(data_path, show_col_types = FALSE)

## Indicators and model ----------------------------------------------------
indicators <- c("COLLGPA", "SATIS28", "SATIS13", "SLFCHG02")
missing_vars <- setdiff(indicators, names(df))
if (length(missing_vars)) stop("Missing variables in dataset: ", paste(missing_vars, collapse = ", "))

cfa_model <- '\n  SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02\n'

## Quick checks & descriptives --------------------------------------------
desc_tbl <- df %>% select(all_of(indicators)) %>%
  summarise(across(everything(), list(n_nonmiss = ~sum(!is.na(.)), n_miss = ~sum(is.na(.)), unique = ~length(unique(na.omit(.))))) )
write_csv(as_tibble(desc_tbl), file.path(out_dir, "cfa_success_descriptives.csv"))

missing_prop <- df %>% select(all_of(indicators)) %>% summarise(across(everything(), ~ mean(is.na(.))))
write_csv(as_tibble(missing_prop), file.path(out_dir, "cfa_success_missing_proportions.csv"))

message("Unique counts per indicator:")
print(map_int(df[indicators], ~ length(unique(na.omit(.)))))

## Convert likely Likert/integer items to ordered factors ------------------
df <- df %>% mutate(across(all_of(indicators), ~ {
  x <- .
  if (!is.ordered(x)) {
    # heuristics: integer/numeric with <=10 uniques, or character -> ordered factor
    if ((is.numeric(x) || is.integer(x)) && length(unique(na.omit(x))) <= 10) {
      ordered(as.factor(x))
    } else if (is.character(x)) {
      ordered(as.factor(x))
    } else {
      x
    }
  } else x
}))

# Save a small preview of the recoded indicators
write_csv(df %>% select(all_of(indicators)) %>% head(200), file.path(out_dir, "cfa_success_indicators_preview.csv"))

## Correlations: use polychoric if all indicators are ordered ----------------
if (all(map_lgl(df[indicators], is.ordered))) {
  message("Computing polychoric correlations (ordinal indicators)")
  # psych::polychoric returns a list; $rho is matrix
  pc <- try(psych::polychoric(df %>% select(all_of(indicators))), silent = TRUE)
  if (!inherits(pc, "try-error")) {
    cor_mat <- pc$rho
    # Ensure cor_mat is a proper matrix and has expected dimensions/names
    if (!is.matrix(cor_mat)) cor_mat <- tryCatch(as.matrix(cor_mat), error = function(e) matrix(as.numeric(unlist(cor_mat)), nrow = length(indicators), ncol = length(indicators)))
    # If dimensions don't match, try to coerce/repair
    if (any(dim(cor_mat) != c(length(indicators), length(indicators)))) {
      dim(cor_mat) <- c(length(indicators), length(indicators))
    }
    # set dimnames to the expected indicators (safe default)
    rownames(cor_mat) <- colnames(cor_mat) <- indicators
    # write safely: prefer tibble with rowname column, fallback to write.csv
    cor_df <- as.data.frame(cor_mat, stringsAsFactors = FALSE)
    cor_df <- tibble::rownames_to_column(cor_df, var = "variable")
    tryCatch({
      write_csv(as_tibble(cor_df), file.path(out_dir, "cfa_success_polychoric_correlations.csv"))
    }, error = function(e) {
      warning("polychoric correlation write failed; falling back to write.csv: ", e$message)
      write.csv(cor_mat, file = file.path(out_dir, "cfa_success_polychoric_correlations.csv"), row.names = TRUE)
    })
  }
} else {
  cor_mat <- cor(df %>% select(all_of(indicators)) %>% mutate(across(everything(), ~ as.numeric(as.character(.)))), use = "pairwise.complete.obs")
  # Ensure proper dimnames and safe write
  if (!is.matrix(cor_mat)) cor_mat <- as.matrix(cor_mat)
  if (is.null(rownames(cor_mat)) || length(rownames(cor_mat)) != length(indicators)) rownames(cor_mat) <- indicators
  if (is.null(colnames(cor_mat)) || length(colnames(cor_mat)) != length(indicators)) colnames(cor_mat) <- indicators
  cor_df <- as.data.frame(cor_mat, stringsAsFactors = FALSE)
  cor_df <- tibble::rownames_to_column(cor_df, var = "variable")
  tryCatch({
    write_csv(as_tibble(cor_df), file.path(out_dir, "cfa_success_pearson_correlations.csv"))
  }, error = function(e) {
    warning("pearson correlation write failed; falling back to write.csv: ", e$message)
    write.csv(cor_mat, file = file.path(out_dir, "cfa_success_pearson_correlations.csv"), row.names = TRUE)
  })
}

## Fit CFA with WLSMV (appropriate for ordinal indicators) -----------------
message("Fitting CFA with WLSMV (ordered = indicators)")
fit <- cfa(cfa_model, data = df, ordered = indicators, estimator = "WLSMV", missing = "listwise")

## Save fit summary and measures -------------------------------------------
sink(file.path(out_dir, "cfa_success_summary.txt"))
print(summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))
sink()

fit_measures <- fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))
write_csv(enframe(fit_measures, name = "measure", value = "value"), file.path(out_dir, "cfa_success_fit_measures.csv"))

## Standardized loadings
std_sol <- standardizedSolution(fit) %>% as_tibble() %>% filter(op == "=~")
write_csv(std_sol, file.path(out_dir, "cfa_success_standardized_loadings.csv"))

## Modification indices (top 20)
mi <- modindices(fit, sort. = TRUE)
if (nrow(mi) > 0) write_csv(as_tibble(mi)[1:min(20, nrow(mi)), ], file.path(out_dir, "cfa_success_modindices_top20.csv"))

## Reliability
alpha_res <- try(psych::alpha(df %>% select(all_of(indicators)) %>% mutate(across(everything(), ~ as.numeric(as.character(.)))), na.rm = TRUE), silent = TRUE)
if (!inherits(alpha_res, "try-error")) {
  capture.output(alpha_res, file = file.path(out_dir, "cfa_success_alpha.txt"))
}
if (!inherits(fit, "try-error")) {
  rel <- try(semTools::reliability(fit), silent = TRUE)
  if (!inherits(rel, "try-error")) capture.output(rel, file = file.path(out_dir, "cfa_success_composite_reliability.txt"))
}

## Factor scores (from WLSMV fit)
fs <- try(lavPredict(fit), silent = TRUE)
if (!inherits(fs, "try-error")) {
  out_scores <- df %>% mutate(SUCCESS_factor = as.numeric(fs)) %>% select(all_of(indicators), SUCCESS_factor)
  write_csv(out_scores, file.path(out_dir, "cfa_success_factor_scores_wls.csv"))
}

## Plot path diagram (png)
plot_file <- file.path(out_dir, "cfa_success_path.png")
try({
  png(plot_file, width = 800, height = 600)
  semPaths(fit, what = "std", layout = "tree", residuals = FALSE, style = "ram", edge.label.cex = 1.2)
  dev.off()
}, silent = TRUE)

## Optional: multiple imputation if missingness non-negligible --------------
miss_props <- df %>% select(all_of(indicators)) %>% summarise(across(everything(), ~ mean(is.na(.)))) %>% unlist()
if (any(miss_props > 0.05)) {
  message("Detected >5% missing on at least one indicator. Running mice (m=5) and pooling via semTools::runMI...")
  imp <- mice(df %>% select(all_of(indicators)), m = 5, seed = 123, printFlag = TRUE)
  runmi_fit <- try(semTools::runMI(model = cfa_model, data = df, mi.obj = imp, fun = 'cfa', ordered = indicators, estimator = 'WLSMV', missing = 'listwise', m = 5, seed = 123), silent = TRUE)
  if (!inherits(runmi_fit, "try-error")) {
    capture.output(summary(runmi_fit), file = file.path(out_dir, "cfa_success_mi_summary.txt"))
    po <- try(semTools::poolEstimates(runmi_fit), silent = TRUE)
    if (!inherits(po, 'try-error')) write_csv(as_tibble(po), file.path(out_dir, "cfa_success_mi_pooled_parameters.csv"))
  }
}

message("CFA complete. Results saved to: ", out_dir)# 1) Update Homebrew and upgrade formulae
brew update
brew upgrade

# 2) Ensure Xcode command-line tools are installed (if not already)
xcode-select --install

# 3) Ensure Fortran/gcc toolchain is available (Homebrew)
brew install gcc
# If gcc is already installed, you may need to reinstall to match latest: brew reinstall gcc

# 4) Install required R packages (CRAN binaries where available)
Rscript -e 'install.packages(c("tidyverse","lavaan","semTools","psych","mice"), repos="https://cloud.r-project.org", dependencies=TRUE)'
