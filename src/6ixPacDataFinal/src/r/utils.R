# Utility functions for the CFA project

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(lavaan)

# Function to load the cleaned dataset
load_clean_data <- function(file_path) {
  data <- read.csv(file_path)
  return(data)
}

# Function to summarize the dataset
summarize_data <- function(data) {
  summary_stats <- data %>%
    summarise(across(everything(), list(mean = mean, sd = sd, min = min, max = max), na.rm = TRUE))
  return(summary_stats)
}

# Function to plot indicator variables
plot_indicators <- function(data, indicators) {
  data_long <- data %>%
    select(all_of(indicators)) %>%
    pivot_longer(cols = everything(), names_to = "Indicator", values_to = "Value")
  
  ggplot(data_long, aes(x = Indicator, y = Value)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Boxplot of Indicator Variables", x = "Indicators", y = "Values")
}