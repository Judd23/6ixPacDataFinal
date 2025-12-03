# Script to fit structural SEM with labeled paths and defined indirects,
# save a text summary and parameter estimates CSV, and save the fitted model.

library(lavaan)

# file paths
file <- "data/clean/OfficialDataset_Final.csv"
out_dir <- "results/sem"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# read data
dat <- read.csv(file, stringsAsFactors = FALSE, check.names = FALSE)

# model with labeled paths for indirect calculations
model_sem <- '
  # structural regressions (labels on key paths)
  HistDisadv_fs ~ h_inc*INCOME + h_fin*FINCON_RC + h_fg*FirstGen_RC + h_hsg*HSGPA + h_fath*FATHEDUC + h_moth*MOTHEDUC + h_cit*CITIZEN + h_race*RACEGROUP + h_undr*UndrRepStud_RC + h_ds*DSstud_RC

  InstitEngage_fs ~ i_hd*HistDisadv_fs + i_inc*INCOME + i_fin*FINCON_RC + i_fg*FirstGen_RC + i_cit2*CITIZEN + i_race*RACEGROUP + i_undr*UndrRepStud_RC + i_ds*DSstud_RC

  Success_Latent ~ s_ie*InstitEngage_fs + s_hd*HistDisadv_fs + s_inc*INCOME + s_fin*FINCON_RC + s_fg*FirstGen_RC + s_hsg*HSGPA + s_cit*CITIZEN + s_race*RACEGROUP + s_undr*UndrRepStud_RC + s_ds*DSstud_RC

  # indirect effects via InstitEngage
  indirect_HistDisadv := i_hd * s_ie

  # SES indirects through HistDisadv -> InstitEngage -> Success
  indirect_INCOME := h_inc * i_hd * s_ie
  indirect_FINCON  := h_fin * i_hd * s_ie
  indirect_FirstGen:= h_fg * i_hd * s_ie

  # Cultural indirects through HistDisadv -> InstitEngage -> Success
  indirect_RACEGROUP    := h_race * i_hd * s_ie
  indirect_UndrRepStud  := h_undr * i_hd * s_ie
'

# fit the SEM
fit_sem <- sem(model_sem, data = dat, meanstructure = TRUE)

# capture summary and fit measures
sum_txt <- capture.output(summary(fit_sem, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE))
writeLines(sum_txt, file.path(out_dir, "structural_model_summary.txt"))

# parameter estimates (including defined parameters)
pe <- parameterEstimates(fit_sem, standardized = TRUE)
write.csv(pe, file.path(out_dir, "structural_model_parameters.csv"), row.names = FALSE)

# save fit object
saveRDS(fit_sem, file.path(out_dir, "structural_model_fit.rds"))

cat("Wrote:", file.path(out_dir, "structural_model_summary.txt"), "\n")
cat("Wrote:", file.path(out_dir, "structural_model_parameters.csv"), "\n")
cat("Wrote:", file.path(out_dir, "structural_model_fit.rds"), "\n")
