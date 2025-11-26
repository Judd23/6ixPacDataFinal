# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/r/cfa`

Confirmatory Factor Analysis scripts live here. They translate the EFA learnings into targeted models, generate fit statistics, and export tables consumed by the report.

### Key contents
- `cfa_success_from_sav.R` — Pipeline that reads the HERI `.sav` files directly.
- `cfa_success_full_fixed.R` and `cfa_success_minimal.R` — Alternative specifications for sensitivity analyses.
- `cfa_success_report.R` — Reporting helpers that format loadings for `reports/`.

### Usage guidelines
- Each script should document its input clean dataset and the output files it writes to `results/cfa/`.
- Keep shared helpers inside `src/r/utils/` and source them here instead of duplicating code.
- When models change, regenerate the downstream SEM inputs and update the relevant READMEs.
