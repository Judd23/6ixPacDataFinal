# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `data/clean`

The datasets in this directory are the analysis-ready outputs that power every downstream script, model, and visualization. They typically include fully documented preprocessing, MICE imputations, feature engineering, and any value labels needed for interpretation.

### Expectations
- File naming should mirror the modeling workflow (`clean_success_outcomes.parquet`).
- Each file should have an accompanying description either in the file header (for CSV) or a short note in this README describing how it was produced.
- Only commit files that can be regenerated from scripts in `src/` to keep the analysis reproducible.

### Usage guidelines
- Analysts should read exclusively from `data/clean/` when running EFA, CFA, SEM, or ML experiments.
- If a new preprocessing pipeline is introduced, document the version in `src/py/README.md` or `src/r/README.md` and regenerate these clean datasets.
