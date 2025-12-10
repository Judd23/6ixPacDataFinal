# Script to fit the requested two-stage linear models (mediator and outcome
# regressions with interactions by RACEGROUP) and compute the indirect effect
# function IE(W).

# file paths
file <- "data/clean/OfficialDataset_Final.csv"
out_dir <- "results/sem"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# read data
df <- read.csv(file, stringsAsFactors = FALSE, check.names = FALSE)

# helper to ensure aliased column names exist (matching requested syntax)
alias_or_stop <- function(alias, fallback) {
  if (alias %in% names(df)) {
    return(invisible(NULL))
  }
  if (fallback %in% names(df)) {
    df[[alias]] <<- df[[fallback]]
    return(invisible(NULL))
  }
  stop(sprintf(
    "Required column '%s' (or fallback '%s') missing from %s",
    alias, fallback, file
  ))
}

base_required <- c(
  "HistDisadv_fs", "InstitEngage_fs", "Success_Latent", "RACEGROUP",
  "INCOME", "HSGPA", "FATHEDUC", "MOTHEDUC", "CITIZEN"
)

missing_base <- setdiff(base_required, names(df))
if (length(missing_base) > 0) {
  stop(
    "These variables are missing from data/clean/OfficialDataset_Final.csv: ",
    paste(missing_base, collapse = ", ")
  )
}

alias_or_stop("FINCON", "FINCON_RC")
alias_or_stop("FrsG_RC", "FirstGen_RC")
alias_or_stop("UnRS_RC", "UndrRepStud_RC")
alias_or_stop("DSst_RC", "DSstud_RC")

# First-stage (M) model
mod_M <- lm(
  InstitEngage_fs ~ HistDisadv_fs * RACEGROUP +
    INCOME + FINCON + FrsG_RC + HSGPA + FATHEDUC + MOTHEDUC +
    CITIZEN + UnRS_RC + DSst_RC,
  data = df
)

# Second-stage (Y) model
mod_Y <- lm(
  Success_Latent ~ HistDisadv_fs * RACEGROUP +
    InstitEngage_fs * RACEGROUP +
    INCOME + FINCON + FrsG_RC + HSGPA + FATHEDUC + MOTHEDUC +
    CITIZEN + UnRS_RC + DSst_RC,
  data = df
)

IE <- function(W, coefs_M, coefs_Y) {
  needed <- c(
    "HistDisadv_fs", "HistDisadv_fs:RACEGROUP",
    "InstitEngage_fs", "InstitEngage_fs:RACEGROUP"
  )
  missing_names <- setdiff(needed, c(names(coefs_M), names(coefs_Y)))
  if (length(missing_names) > 0) {
    stop(
      "Missing coefficients needed for IE calculation: ",
      paste(missing_names, collapse = ", ")
    )
  }
  a1 <- coefs_M["HistDisadv_fs"]
  a3 <- coefs_M["HistDisadv_fs:RACEGROUP"]
  b1 <- coefs_Y["InstitEngage_fs"]
  b3 <- coefs_Y["InstitEngage_fs:RACEGROUP"]
  (a1 + a3 * W) * (b1 + b3 * W)
}

coefs_M <- coef(mod_M)
coefs_Y <- coef(mod_Y)

unique_race_values <- sort(unique(df$RACEGROUP))
ie_values <- data.frame(
  RACEGROUP = unique_race_values,
  indirect_effect = vapply(
    unique_race_values,
    IE,
    numeric(1),
    coefs_M = coefs_M,
    coefs_Y = coefs_Y
  )
)

writeLines(
  capture.output(summary(mod_M)),
  file.path(out_dir, "first_stage_model_summary.txt")
)
writeLines(
  capture.output(summary(mod_Y)),
  file.path(out_dir, "second_stage_model_summary.txt")
)
write.csv(
  ie_values,
  file.path(out_dir, "indirect_effects_by_racegroup.csv"),
  row.names = FALSE
)

saveRDS(mod_M, file.path(out_dir, "first_stage_model_fit.rds"))
saveRDS(mod_Y, file.path(out_dir, "second_stage_model_fit.rds"))

cat("Wrote:", file.path(out_dir, "first_stage_model_summary.txt"), "\n")
cat("Wrote:", file.path(out_dir, "second_stage_model_summary.txt"), "\n")
cat("Wrote:", file.path(out_dir, "indirect_effects_by_racegroup.csv"), "\n")
cat("Wrote:", file.path(out_dir, "first_stage_model_fit.rds"), "\n")
cat("Wrote:", file.path(out_dir, "second_stage_model_fit.rds"), "\n")
