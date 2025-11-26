# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `src/sas`

Legacy SAS programs live here for initial descriptive analytics, validation checks on the HERI extracts, and any regulatory reporting that must be produced in SAS.

### Key contents
- Data-quality checks that validate raw HERI files against documentation.
- Early descriptive summaries shared with stakeholders before the R workflow is finalized.
- Scripts that recreate the `Program Summary` PDFs stored in `reports/Figures/`.

### Usage guidelines
- Keep SAS logs and listings out of version control (they belong in `.gitignore`).
- Document input/output locations at the top of each `.sas` file so analysts can rerun them as needed.
- When a SAS script hands off to R/Python, note the downstream script in comments for traceability.
