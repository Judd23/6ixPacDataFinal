# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `results/efa`

Exploratory Factor Analysis diagnostics live here: scree plots, loading tables, factor score exports, and rotation comparisons produced while designing the latent structure.

### Key contents
- Scree plots and proportion-of-variance tables.
- Loading matrices (wide and tidy formats) that inform CFA specifications.
- Factor score exports that feed downstream SEM or ML experiments.

### Usage guidelines
- Keep filenames aligned with the dataset and preprocessing version (e.g., `efa_success_rotated_v3.csv`).
- Document the script or notebook that produced each artifact so results remain reproducible.
- Do **not** store code—only generated outputs belong here.
