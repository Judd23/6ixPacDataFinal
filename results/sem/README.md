# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `results/sem`

Structural Equation Modeling outputs—fit indices, standardized solutions, path diagrams, and supporting diagnostics—belong in this directory so the final report tables can be regenerated quickly.

### Key contents
- Mplus/lavaan summaries exported from `src/r/sem/` scripts.
- Standardized path coefficients and covariance matrices.
- Figures or tables (PDF/PNG/CSV) that flow into `reports/`.

### Usage guidelines
- Keep code elsewhere; this folder should contain generated artifacts only.
- Use subfolders such as `figures/`, `tables/`, or run-specific timestamps when analyses branch.
- Note the producing script and data version in a short `.txt` sidecar or within file metadata for traceability.
