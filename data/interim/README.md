# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `data/interim`

Use this space for temporary, versioned preprocessing outputs: merges, partial cleaning steps, imputations in progress, or sanity-check subsets that sit between the raw intake and the final cleaned data.

### Typical artifacts
- Working parquet/CSV files produced during iterative cleaning.
- Diagnostics from imputation or transformation routines.
- Short-lived exports that feed exploratory notebooks.

### Usage guidelines
- Prefix filenames with the step or date (`2025-11-25_imputed.parquet`) so teammates can follow the workflow.
- When a file becomes final, move it into `data/clean/` and document the decision in the relevant `src/` script README.
- Clean up obsolete intermediates regularly to keep the repository approachable for new contributors.
