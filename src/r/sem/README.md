# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/r/sem`

This directory will host the Structural Equation Modeling scripts that extend the CFA results into multivariate path models, indirect effects, and longitudinal comparisons.

### Expected contents
- Lavaan model definitions sourcing inputs from `results/cfa/` or `data/clean/`.
- Helper scripts that produce standardized solutions, path diagrams, and residual diagnostics.
- Export routines that write SEM outputs to `results/sem/`.

### Usage guidelines
- Reuse loaders and plotting utilities from `src/r/utils/` instead of copying code.
- Tag each script with the clean dataset version and note the SEM figure/table it produces.
- Whenever SEM specifications change, update this README so contributors know the current workflow stage.
