# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `results/cfa`

Confirmatory Factor Analysis outputs live here—fit indices, standardized loadings, residual diagnostics, and figures that summarize the vetted models.

### Key contents
- Fit summaries exported from `src/r/cfa/` scripts.
- Standardized loadings tables ready for the final report.
- Residual plots or modification indices saved for model refinement.

### Usage guidelines
- Keep filenames aligned with the CFA script and dataset version (e.g., `cfa_success_full_v2.csv`).
- When a file migrates into `reports/Figures/`, keep a copy or link here for provenance.
- Store only generated artifacts; scripts themselves belong inside `src/`.
