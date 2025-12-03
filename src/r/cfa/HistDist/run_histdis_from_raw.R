suppressPackageStartupMessages({
  library(haven)
  library(lavaan)
  library(dplyr)
})

raw_path <- file.path("data", "raw", "2025_ED_852_HERI_data.sav")
out_dir <- file.path("results", "cfa")
if (!file.exists(raw_path)) stop("Raw SPSS file not found at ", raw_path)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_sav(raw_path)
# create FirstGen_raw: assume parental education codes where 4+ indicates BA or higher
# If both parents have values and both < 4 => first-gen
fath <- df$FATHEDUC
moth <- df$MOTHEDUC

FirstGen_raw <- rep(NA_integer_, nrow(df))
# only set when both non-missing
ok <- !is.na(fath) & !is.na(moth)
FirstGen_raw[ok] <- as.integer((fath[ok] < 4) & (moth[ok] < 4))

# UndrRep_raw from CSSRACE* (1/0 indicators). Define URM as CSSRACE2,3,5,6,7,8
race_vars <- c("CSSRACE2","CSSRACE3","CSSRACE5","CSSRACE6","CSSRACE7","CSSRACE8")
present <- race_vars %in% names(df)
if (!all(present)) stop("Expected race indicator variables not found in raw data: ", paste(race_vars[!present], collapse=", "))
race_mat <- as.data.frame(df[, race_vars])
UndrRep_raw <- as.integer(apply(race_mat, 1, function(x) any(x == 1, na.rm = TRUE)))

# FINCON exists
if (!("FINCON" %in% names(df))) stop("FINCON not found in raw data")
FINCON_raw <- df$FINCON

# assemble analysis data (keep rows where at least one indicator non-missing)
an_df <- data.frame(FirstGen_raw = FirstGen_raw, UndrRep_raw = UndrRep_raw, FINCON_raw = FINCON_raw)

# quick check counts
write.csv(data.frame(variable = names(an_df), non_missing = sapply(an_df, function(x) sum(!is.na(x)))), file = file.path(out_dir, "histdis_raw_indicator_counts.csv"), row.names = FALSE)

# Convert indicators to ordered factors (categorical) and use WLSMV estimator
an_df <- an_df %>% mutate(across(everything(), ~ ifelse(is.na(.), NA, as.integer(.))))
an_df_ord <- an_df %>% mutate(across(everything(), ~ ordered(.)))

model <- '\nHistDisadv =~ FirstGen_raw + UndrRep_raw + FINCON_raw\n'
fit <- tryCatch(
  lavaan::cfa(model, data = an_df_ord, ordered = names(an_df_ord), estimator = "WLSMV", missing = "pairwise"),
  error = function(e) {
    message('WLSMV failed, falling back to ML on numeric indicators: ', e$message)
    lavaan::lavaan(model, data = an_df, meanstructure = TRUE, missing = "fiml", fixed.x = TRUE)
  }
)

# Save outputs
saveRDS(fit, file = file.path(out_dir, "histdis_fit_from_raw.rds"))
pe <- parameterEstimates(fit, standardized = TRUE)
write.csv(pe, file = file.path(out_dir, "histdis_parameters_full_from_raw.csv"), row.names = FALSE)
loadings <- subset(pe, op == "=~")
write.csv(loadings, file = file.path(out_dir, "histdis_loadings_from_raw.csv"), row.names = FALSE)
write.csv(data.frame(inspect(fit, "r2")), file = file.path(out_dir, "histdis_r2_from_raw.csv"), row.names = TRUE)
fm <- fitMeasures(fit, c("chisq","df","pvalue","cfi","tli","rmsea","srmr"))
write.csv(data.frame(measure = names(fm), value = as.numeric(fm)), file = file.path(out_dir, "histdis_fit_measures_from_raw.csv"), row.names = FALSE)

cat("Saved fit and parameter files to", normalizePath(out_dir), "\n")
print(fit)
