#!/usr/bin/env Rscript
# Lightweight CFA runner requiring only lavaan and psych (haven optional for .sav files)

args <- commandArgs(trailingOnly = TRUE)
data_path <- ifelse(length(args) >= 1, args[1], "data/interim/df_subset.csv")
out_dir <- "results"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

needed <- c("lavaan", "psych")
missing_pkgs <- needed[!sapply(needed, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  message("Missing required R packages: ", paste(missing_pkgs, collapse = ", "))
  message("Install them with Rscript -e 'install.packages(c(\"lavaan\",\"psych\",\"semTools\"), repos=\"https://cloud.r-project.org\")')")
  quit(status = 1)
}

read_data <- function(path) {
  if (grepl("\\.sav$", path, ignore.case = TRUE)) {
    if (requireNamespace("haven", quietly = TRUE)) {
      return(as.data.frame(haven::read_sav(path)))
    } else {
      stop("File is .sav but package 'haven' is not installed. Install haven or convert to CSV.")
    }
  } else {
    return(utils::read.csv(path, stringsAsFactors = FALSE))
  }
}

if (!file.exists(data_path)) stop("Data file not found: ", data_path)
df <- read_data(data_path)

indicators <- c("SATIS28", "SUCCESS4", "SUCCESS7", "SLFCHG09", "SLFCHG02")
missing_vars <- setdiff(indicators, names(df))
if (length(missing_vars)) stop("Missing variables in dataset: ", paste(missing_vars, collapse = ", "))

cfa_model <- 'SUCCESS =~ 1*SATIS28 + SUCCESS4 + SUCCESS7 + SLFCHG09 + SLFCHG02'

miss_prop <- sapply(df[indicators], function(x) mean(is.na(x)))
miss_df <- data.frame(variable = names(miss_prop), prop_missing = as.numeric(miss_prop), stringsAsFactors = FALSE)
write.csv(miss_df, file.path(out_dir, "cfa_success_missing_props_light.csv"), row.names = FALSE)

to_ordered <- function(x) {
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
  if (is.numeric(x)) {
    if (all(is.na(x))) return(ordered(as.factor(x)))
    return(ordered(as.factor(x)))
  }
  return(ordered(as.factor(x)))
}

df[indicators] <- lapply(df[indicators], to_ordered)

library(lavaan)

message("Fitting CFA with WLSMV (ordered indicators, SATIS28 anchored to 1)")
fit <- NULL
tryCatch({
  fit <- lavaan::cfa(cfa_model, data = df, estimator = "WLSMV", ordered = indicators)
}, error = function(e) {
  message("WLSMV fit failed: ", e$message)
  quit(status = 2)
})

sink(file.path(out_dir, "cfa_success_light_summary.txt"))
print(summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))
sink()

fm <- tryCatch(lavaan::fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr")), error = function(e) NULL)
if (!is.null(fm)) {
  fm_df <- data.frame(measure = names(fm), value = as.numeric(fm), stringsAsFactors = FALSE)
  write.csv(fm_df, file.path(out_dir, "cfa_success_fit_measures_light.csv"), row.names = FALSE)
}

std <- tryCatch(lavaan::standardizedSolution(fit), error = function(e) NULL)
if (!is.null(std)) {
  std_df <- as.data.frame(std)
  rownames(std_df) <- NULL
  write.csv(std_df, file.path(out_dir, "cfa_success_standardized_solution_light.csv"), row.names = FALSE)
}

fs <- tryCatch(lavPredict(fit), error = function(e) NULL)
if (!is.null(fs)) {
  fs_df <- data.frame(SUCCESS_factor = as.numeric(fs))
  write.csv(fs_df, file.path(out_dir, "cfa_success_factor_scores_light.csv"), row.names = FALSE)
}

message("Lightweight CFA complete. Outputs in: ", out_dir)
