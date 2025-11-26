# 6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. The goal of this organization is to make the project accessible for beginners while supporting advanced reproducible statistical analysis.

## Folder focus: `docs/Survey_Instruments`

The original HERI questionnaires live here so analysts can trace every variable back to the exact wording presented to study participants.

### Key contents
- `2000FreshmenSurvey_instrument.pdf` — Instrument administered to the entering freshmen cohort.
- `2004SeniorSurvey_instrument.pdf` — Follow-up questionnaire for the same cohort at graduation.
- Any addenda or IRB memos associated with the surveys.

### Usage guidelines
- Reference these PDFs when creating derived indicators or interpreting latent constructs in the reports.
- Keep the files immutable; add explanatory notes in `docs/README.md` or `data/variable_table/` instead of editing the originals.
- When new survey waves are added, follow the same naming convention and document them here.
