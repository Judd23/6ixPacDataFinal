# Load necessary libraries
library(lavaan)

# Load the dataset 'df_subset' per request
data <- read.csv("data/interim/df_subset.csv")

# Specify the CFA model for the latent variable "SUCCESS"
model <- '
  SUCCESS =~ COLLGPA + SATIS28 + SATIS13 + SLFCHG02
'

# Fit the CFA model
fit <- cfa(model, data = data)

# Summary of the CFA results
summary(fit, fit.measures = TRUE, standardized = TRUE)

# Save the results to a file
sink("results/cfa_success_results.txt")
summary(fit, fit.measures = TRUE, standardized = TRUE)
sink()


