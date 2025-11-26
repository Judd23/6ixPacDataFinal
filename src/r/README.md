# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/r`

All R code for the statistical modeling workflow lives here, organized to mirror the EFA → CFA → SEM progression plus shared utilities.

### Subfolders
- `efa/` (coming soon) — Exploratory Factor Analysis scripts that diagnose latent structure.
- `cfa/` — Confirmatory Factor Analysis specifications and reporting helpers.
- `sem/` — Structural Equation Modeling scripts (currently being populated).
- `utils/` — Shared loaders (`load_data.R`, `load_lvd.R`), plotting helpers, and reusable functions.

### Usage guidelines
- Keep scripts self-documenting by noting their input data (`data/clean/...`) and output targets (`results/...`).
- When analysis steps change, update the corresponding README and regenerate downstream results so the pipeline stays reproducible.
- Prefer sourcing shared code from `utils/` instead of copying functions between CFA/SEM folders.
