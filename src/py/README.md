# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/py`

Python scripts power data ingestion, cleaning, exploratory data analysis, and machine-learning experiments that complement the R-based factor modeling.

### Key contents
- Data processing modules that output the `data/clean/` files.
- Notebook-friendly utilities for visualization and descriptive statistics.
- Experimental ML pipelines stored as scripts or notebooks that write to `results/`.

### Usage guidelines
- Keep scripts modular and document the expected input/output paths at the top of each file.
- When notebooks graduate into production workflows, convert reusable pieces into modules within this folder.
- Note any environment requirements (conda, pip) in the project root README or a `requirements.txt` for easy onboarding.
