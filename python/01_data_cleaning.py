"""
ATM Operations & Cash Management Analytics
File: 01_data_cleaning.py

Loads the source Excel workbook, standardizes column names and
text values, and exports a cleaned workbook and quality report.
"""

from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"

INPUT_FILE = DATA_DIR / "ATM_Operations_Cash_Management_Analytics (3).xlsx"
OUTPUT_FILE = DATA_DIR / "ATM_Analytics_Cleaned.xlsx"
REPORT_FILE = DATA_DIR / "data_quality_report.csv"


def main():
    if not INPUT_FILE.exists():
        raise FileNotFoundError(f"Source workbook not found: {INPUT_FILE}")

    workbook = pd.read_excel(INPUT_FILE, sheet_name=None)
    cleaned_sheets = {}
    quality_results = []

    for sheet_name, df in workbook.items():
        df = df.copy()

        df.columns = [
            str(col).strip().lower().replace(" ", "_").replace("-", "_")
            for col in df.columns
        ]

        for col in df.select_dtypes(include=["object", "string"]).columns:
            df[col] = df[col].map(
                lambda value: value.strip() if isinstance(value, str) else value
            )

        df = df.replace(r"^\s*$", pd.NA, regex=True)

        quality_results.append({
            "sheet_name": sheet_name,
            "rows": len(df),
            "columns": len(df.columns),
            "missing_cells": int(df.isna().sum().sum()),
            "duplicate_rows": int(df.duplicated().sum())
        })

        cleaned_sheets[sheet_name] = df

    with pd.ExcelWriter(OUTPUT_FILE, engine="openpyxl") as writer:
        for sheet_name, df in cleaned_sheets.items():
            df.to_excel(writer, sheet_name=sheet_name[:31], index=False)

    pd.DataFrame(quality_results).to_csv(REPORT_FILE, index=False)

    print("Data cleaning completed.")
    print("Cleaned workbook:", OUTPUT_FILE)
    print("Quality report:", REPORT_FILE)


if __name__ == "__main__":
    main()
