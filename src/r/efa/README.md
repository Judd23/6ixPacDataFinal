# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/r/efa`

Exploratory Factor Analysis scripts kick off the modeling workflow here. These routines explore latent structures, test extraction methods, and create artifacts that guide CFA/SEM specifications.

### Expected contents
- Scripts for running parallel analysis, scree plots, and rotation comparisons.
- Functions that export loading matrices and factor scores into `results/efa/`.
- Notebook shims or wrappers that prepare data subsets for experimentation.

### Usage guidelines
- Version filenames to match the dataset/preprocessing stage used (`efa_success_clean_v1.R`).
- When a script writes outputs, document the destination path inside the file header.
- Promote reusable logic into `src/r/utils/` once it stabilizes.
