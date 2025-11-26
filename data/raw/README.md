6ixPacDataFinal – STAT 520 Final Project Repository

This repository contains the full workflow for the STAT 520 project, including data management, exploratory analysis, factor analysis, structural modeling, visualizations, and the final report materials. 
Folder focus: `data/raw`

This directory stores the unmodified HERI datasets, accompanying codebooks, and any intake documentation exactly as received from the source. Keeping these files pristine ensures we can always trace analyses back to the original instruments.

Contents
- Source survey exports (`*.sav`, `*.por`, etc.).
- Official metadata delivered alongside the raw data.
- Read-only artifacts that describe how the data were collected.

Usage guidelines
- Do **not** edit or overwrite files here; make copies into `data/interim/` before transforming anything.
