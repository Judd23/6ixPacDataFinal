# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `results/`

All model outputs live here, organized by method (`efa/`, `cfa/`, `sem/`, plus machine-learning experiments). Files include fit statistics, factor scores, standardized solutions, path diagrams, and the tables used in the final report.

### Expectations
- Store only generated artifacts—no source code. Each file should be reproducible by re-running the corresponding script in `src/`.
- Use meaningful subfolders or timestamps so reviewers can connect outputs to specific analysis runs.
- Keep heavy assets (figures, tables) synced with `reports/Figures/` when they appear in the written report.

### Quick reference
- `results/efa/` — Exploratory Factor Analysis diagnostics and loadings.
- `results/cfa/` — Confirmatory Factor Analysis outputs.
- `results/sem/` — Structural Equation Modeling fit summaries and diagrams.
- `results/Machine_Learning.ipynb` — Notebook capturing experimental models that feed comparison tables.
