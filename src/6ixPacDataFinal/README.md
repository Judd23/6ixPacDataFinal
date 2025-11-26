# 6ixPacDataFinal Project

## Overview
The 6ixPacDataFinal project aims to conduct a comprehensive analysis using the HERI dataset. The primary focus is on performing Confirmatory Factor Analysis (CFA) to validate the latent variable "SUCCESS" through various indicator variables.

## Project Structure
- **data/**
  - **raw/**: Contains untouched HERI data and codebooks.
  - **interim/**: Temporary files for data merging and cleaning.
  - **clean/**: Final cleaned dataset (`final.csv`) used for analysis.
  
- **src/**
  - **r/**
    - **cfa/**: Contains scripts for conducting CFA.
      - `cfa_success.R`: R script for CFA model specification and fitting.
      - `cfa_success.Rmd`: R Markdown document for narrative and visual output of CFA results.
    - `load_data.R`: Script for loading the cleaned dataset into R.
    - `utils.R`: Utility functions for data manipulation and visualization.
  
- **reports/**: Directory for storing figures and visual outputs generated from the analysis.

- **docs/**: Documentation including data dictionaries and meeting notes.

- **results/**: Directory for saving models, metrics, and other results from the analysis.

- **tests/**: Contains tests for validating the CFA implementation.
  - `test_cfa.R`: Tests to ensure the CFA model runs correctly and produces expected outputs.

## Setup Instructions
1. **Install Required Packages**: Ensure that the necessary R packages are installed, including `lavaan` for CFA.
2. **Load Data**: Use the `load_data.R` script to load the cleaned dataset from `data/clean/final.csv`.
3. **Run CFA**: Execute the `cfa_success.R` script to perform the CFA for the latent variable "SUCCESS".
4. **Review Results**: Check the `cfa_success.Rmd` file for a detailed report of the CFA results, including plots and tables.

## Usage Guidelines
- Follow the project structure for organizing files and outputs.
- Ensure reproducibility by using set.seed() for any random processes.
- Document any changes made to scripts or data in the project repository.

## Contribution
Contributions to the project are welcome. Please follow the Git workflow for making changes and submitting pull requests.