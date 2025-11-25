# Test CFA for SUCCESS Latent Variable

# Load necessary libraries
library(lavaan)
library(readr)

# Load the cleaned dataset
data <- read_csv("data/clean/final.csv")

# Specify the CFA model for the latent variable "SUCCESS"
cfa_model <- '
  SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02
'

# Fit the CFA model
fit <- cfa(cfa_model, data = data)

# Summary of the CFA model fit
summary(fit, fit.measures = TRUE, standardized = TRUE)

# Check for model fit indices
fit_indices <- fitMeasures(fit)
print(fit_indices)

# Test if the model converged
if (fit@optim$converged) {
  cat("The model has converged successfully.\n")
} else {
  cat("The model did not converge.\n")
}

# Save the fit results for further analysis
saveRDS(fit, file = "results/cfa_success_fit.rds")
