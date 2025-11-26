# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/r/utils`

Common helper scripts—data loaders, labeling utilities, plotting helpers, and shared constants—live here for reuse across EFA, CFA, and SEM workflows.

### Key contents
- `load_data.R` — Primary loader for clean datasets.
- `load_lvd.R` — Loader for latent variable dictionaries and metadata.
- Any future helper modules (e.g., plotting themes, table-formatting helpers).

### Usage guidelines
- Keep functions general-purpose; analysis-specific logic belongs in the CFA/SEM folders.
- Document return types and expected file paths at the top of each script for quick onboarding.
- When new utilities are added, update this README so collaborators know what to source.
