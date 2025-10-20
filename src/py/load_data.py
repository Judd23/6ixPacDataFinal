"""Load the SPSS .sav dataset for analysis.

This script uses pandas + pyreadstat to read the .sav file and returns a DataFrame.

Usage:
    python src/py/load_data.py

It assumes the data file is at: ../6ix_Pac_Data_Stats520-Final-Project/data/raw/2025_ED_852_HERI_data.sav
or you can pass a path as the first argument.
"""
from pathlib import Path
import sys

try:
    import pandas as pd
    import pyreadstat
except Exception as e:
    print("Missing dependencies. Install with: pip install pandas pyreadstat")
    raise


def load_sav(path: Path):
    """Read an SPSS .sav file and return a pandas DataFrame and metadata."""
    df, meta = pyreadstat.read_sav(str(path))
    return df, meta


if __name__ == '__main__':
    default_path = Path(__file__).resolve().parents[2] / '6ix_Pac_Data_Stats520-Final-Project' / 'data' / 'raw' / '2025_ED_852_HERI_data.sav'
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else default_path
    print(f"Loading: {path}")
    df, meta = load_sav(path)
    print(f"Loaded {len(df)} rows and {len(df.columns)} columns")
    # show first few rows
    print(df.head().to_string())
