# Load the necessary libraries
library(readr)

# Define the path to the cleaned dataset
data_path <- "data/clean/final.csv"

# Load the dataset into R
load_data <- function() {
  data <- read_csv(data_path)
  return(data)
}

# Call the function to load the data
dataset <- load_data()