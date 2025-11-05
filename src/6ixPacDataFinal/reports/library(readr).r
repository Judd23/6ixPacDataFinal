library(readr)
library(gt)        # nice table formatting
library(apaTables)
library(haven)

fit <- read_csv("results/cfa_success_fit_measures_light.csv")
loadings <- read_csv("results/cfa_success_standardized_solution_light.csv")
df <- as.data.frame(read_sav("/Users/jjohnson3/StatsFullData.sav"))

# Fit measures in APA style
fit_table <- gt(fit) %>%
  fmt_number(columns = "value", decimals = 3) %>%
  cols_label(measure = "Statistic", value = "Value") %>%
  tab_header(title = "CFA Fit Indices")
gtsave(fit_table, "results/cfa_success_fit_apa.html")

# Loadings table
loading_table <- loadings |> 
  dplyr::filter(op == "=~") |> 
  dplyr::select(lhs, rhs, est.std, se, z) %>%
  gt() %>%
  fmt_number(columns = c("est.std","se","z"), decimals = 3) %>%
  cols_label(lhs = "Factor", rhs = "Indicator", est.std = "Std Loading", se = "SE", z = "z") %>%
  tab_header(title = "Standardized Loadings")
gtsave(loading_table, "results/cfa_success_loadings_apa.html")
