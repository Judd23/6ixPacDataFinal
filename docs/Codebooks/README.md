# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `docs/Codebooks`

Authoritative HERI variable dictionaries and response maps live here so analysts can interpret every field in `data/raw/` and document derived features.

### Key contents
- `2000FreshmenSurvey_Codebook.pdf` — Variable definitions and coding for the entering cohort.
- `2004SeniorSurvey_Codebook.pdf` — Follow-up definitions for the graduation cohort.
- Any supplemental lookup tables that back the `data/variable_table/` workbook.

### Usage guidelines
- Never edit PDFs directly; add clarifying notes in the variable table instead.
- Cite the exact page/section in analysis notebooks when referencing a specific indicator.
- Update this README whenever new documentation is added so the directory stays beginner friendly.
