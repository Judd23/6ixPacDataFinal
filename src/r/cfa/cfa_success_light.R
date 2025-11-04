#!/usr/bin/env Rscript
# Lightweight CFA runner: minimal dependencies (lavaan, psych, haven/readr optional)
# Produces fit measures and standardized loadings using base R I/O.

args <- commandArgs(trailingOnly = TRUE)
data_path <- ifelse(length(args) >= 1, args[1], "data/interim/df_subset.csv")
out_dir <- "results"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

needed <- c("lavaan", "psych")
missing_pkgs <- needed[!sapply(needed, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  message("Missing required R packages: ", paste(missing_pkgs, collapse = ", "))
  message("Install them with e.g. Rscript -e 'install.packages(c(\"lavaan\",\"psych\"), repos=\"https://cloud.r-project.org\")')")
  quit(status = 1)
}

# helper to read SPSS if needed (haven optional)
read_data <- function(path) {
  if (grepl("\\.sav$", path, ignore.case = TRUE)) {
    if (requireNamespace("haven", quietly = TRUE)) {
      return(as.data.frame(haven::read_sav(path)))
    } else {
      stop("File is .sav but package 'haven' is not installed. Install haven or convert to CSV.")
    }
  } else {
    # CSV
    return(utils::read.csv(path, stringsAsFactors = FALSE))
  }
}

if (!file.exists(data_path)) stop("Data file not found: ", data_path)
df <- read_data(data_path)

# User-specified indicators and model (edit here if names differ)
indicators <- c("COLLGPA", "SATIS28", "SATIS13", "SLFCHG02")
missing_vars <- setdiff(indicators, names(df))
if (length(missing_vars) > 0) stop("Missing variables in dataset: ", paste(missing_vars, collapse = ", "))

cfa_model <- 'SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02'

# quick missingness summary
miss_prop <- sapply(df[indicators], function(x) mean(is.na(x)))
write.csv(data.frame(variable = names(miss_prop), prop_missing = as.numeric(miss_prop)), file.path(out_dir, "cfa_success_missing_props_light.csv"), row.names = FALSE)

# heuristics: treat ordered if integer/character with <=10 uniques
is_ord <- sapply(df[indicators], function(x) {
  ux <- unique(na.omit(x))
  (is.character(x) || (is.numeric(x) && length(ux) <= 10))
})

# coerce to ordered where appropriate
for (v in indicators[is_ord]) {
  df[[v]] <- ordered(as.factor(df[[v]]))
}

# Decide method: if all ordered -> WLSMV with ordered indicators (may still require lavaan compiled support)
library(lavaan)
all_ordered <- all(sapply(df[indicators], is.ordered))

fit <- NULL
tryCatch({
  if (all_ordered) {
    message("Fitting WLSMV with ordered indicators (listwise)")
    fit <- lavaan::cfa(cfa_model, data = df, ordered = indicators, estimator = "WLSMV", missing = "listwise")
  } else {
    message("Fitting MLR with FIML (treating indicators as continuous)")
    # convert ordered factors to numeric for FIML
    for (v in indicators) {
      if (is.ordered(df[[v]]) || is.factor(df[[v]])) df[[v]] <- as.numeric(as.character(df[[v]]))
    }
    fit <- lavaan::cfa(cfa_model, data = df, estimator = "MLR", missing = "fiml")
  }
}, error = function(e) {
  message("Model fit failed: ", e$message)
  quit(status = 2)
})

# Save summary and outputs
sink(file.path(out_dir, "cfa_success_light_summary.txt"))
print(summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))
sink()

fm <- tryCatch({
  lavaan::fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))
}, error = function(e) NULL)
if (!is.null(fm)) write.csv(as.data.frame(t(fm)), file.path(out_dir, "cfa_success_fit_measures_light.csv"), row.names = FALSE)

std <- tryCatch({
  lavaan::standardizedSolution(fit)
}, error = function(e) NULL)
if (!is.null(std)) write.csv(std, file.path(out_dir, "cfa_success_standardized_solution_light.csv"), row.names = FALSE)

# factor scores (if available)
fs <- tryCatch({ lavPredict(fit) }, error = function(e) NULL)
if (!is.null(fs)) write.csv(data.frame(SUCCESS_factor = as.numeric(fs)), file.path(out_dir, "cfa_success_factor_scores_light.csv"), row.names = FALSE)

message("Lightweight CFA complete. Outputs in: ", out_dir)
