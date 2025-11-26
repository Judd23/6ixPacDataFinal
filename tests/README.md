# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `tests/`

This directory hosts lightweight regression tests and validation scripts that ensure data pipelines, model code, and reporting templates continue to run as expected.

### Key contents
- Unit-style checks for data loaders (R/Python) and helper utilities.
- Smoke tests confirming notebooks execute end-to-end on sample data.
- Validation scripts verifying model outputs match expected schemas.

### Usage guidelines
- Add a new test whenever a bug is fixed or a new workflow is introduced.
- Keep tests fast so they can run before every commit; store heavy integration checks in notebooks under `results/`.
- Document how to run the suite (e.g., `pytest`, `R CMD check`) inside this folder once the tooling is standardized.
