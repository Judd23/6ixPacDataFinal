# Load SPSS .sav file in R using haven
# Usage: Rscript src/r/load_data.R [path/to/2025_ED_852_HERI_data.sav]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1) {
  file_path <- args[1]
} else {
  file_path <- file.path("..","6ix_Pac_Data_Stats520-Final-Project","data","raw","2025_ED_852_HERI_data.sav")
}

if (!requireNamespace("haven", quietly = TRUE)) {
  stop("Please install the 'haven' package: install.packages('haven')")
}

library(haven)

cat("Loading:", file_path, "\n")
df <- read_sav(file_path)
cat("Loaded rows:", nrow(df), "columns:", ncol(df), "\n")
print(utils::head(df))
