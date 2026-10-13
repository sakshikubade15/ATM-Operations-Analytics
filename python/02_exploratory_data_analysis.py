"""
ATM Operations & Cash Management Analytics
File: 02_exploratory_data_analysis.py

Purpose:
- Calculate transaction KPIs.
- Summarize transaction status, type, city, and hour.
- Generate charts for the project images folder.
"""

from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"
IMAGE_DIR = PROJECT_DIR / "images"

INPUT_FILE = DATA_DIR / "ATM_Analytics_Cleaned.xlsx"
IMAGE_DIR.mkdir(parents=True, exist_ok=True)


def find_sheet(sheets, keyword):
    """Find a workbook sheet using a case-insensitive keyword."""
    for name, df in sheets.items():
        if keyword in name.lower():
            return df.copy()
    return None


def main():
    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"Cleaned workbook not found: {INPUT_FILE}. "
            "Run 01_data_cleaning.py first."
        )

    sheets = pd.read_excel(INPUT_FILE, sheet_name=None)

    # Locate the transaction sheet using its sheet name
    transactions = find_sheet(sheets, "transaction")
    if transactions is None:
        raise ValueError(
            f"No transaction sheet found. Available sheets: {list(sheets)}"
        )

    # Normalize column names in case the workbook uses mixed capitalization
    transactions.columns = [
        str(c).strip().lower().replace(" ", "_").replace("-", "_")
        for c in transactions.columns
    ]

    required = {"status", "amount"}
    missing = required - set(transactions.columns)
    if missing:
        raise ValueError(f"Missing required transaction columns: {missing}")

    transactions["status"] = (
        transactions["status"].astype("string").str.strip().str.lower()
    )
    transactions["amount"] = pd.to_numeric(
        transactions["amount"], errors="coerce"
    )

    total = len(transactions)
    successful = int((transactions["status"] == "successful").sum())
    failed = int((transactions["status"] == "failed").sum())
    success_rate = successful * 100 / total if total else 0

    print("\nATM TRANSACTION KPI SUMMARY")
    print("=" * 40)
    print(f"Total transactions: {total:,}")
    print(f"Successful transactions: {successful:,}")
    print(f"Failed transactions: {failed:,}")
    print(f"Success rate: {success_rate:.2f}%")

    # 1. Transaction status chart
    status_counts = transactions["status"].fillna("missing").value_counts()
    ax = status_counts.plot(kind="bar", title="Transactions by Status")
    ax.set_xlabel("Status")
    ax.set_ylabel("Number of Transactions")
    plt.tight_layout()
    plt.savefig(IMAGE_DIR / "eda_transaction_status.png", dpi=150)
    plt.show()
    plt.close()

    # 2. Transaction type chart, if available
    if "transaction_type" in transactions.columns:
        type_counts = transactions["transaction_type"].value_counts()
        ax = type_counts.plot(kind="bar", title="Transactions by Type")
        ax.set_xlabel("Transaction Type")
        ax.set_ylabel("Number of Transactions")
        plt.tight_layout()
        plt.savefig(IMAGE_DIR / "eda_transaction_types.png", dpi=150)
        plt.show()
        plt.close()

    # 3. City chart, if city exists in the transaction sheet
    # Otherwise, join the ATM sheet if it has the required fields.
    city_data = transactions.copy()
    if "city" not in city_data.columns:
        atms = find_sheet(sheets, "atm")
        if atms is not None:
            atms.columns = [
                str(c).strip().lower().replace(" ", "_").replace("-", "_")
                for c in atms.columns
            ]
            if {"atm_id", "city"}.issubset(atms.columns) and "atm_id" in city_data.columns:
                city_data = city_data.merge(
                    atms[["atm_id", "city"]].drop_duplicates("atm_id"),
                    on="atm_id",
                    how="left"
                )

    if "city" in city_data.columns:
        city_counts = city_data["city"].fillna("Unknown").value_counts()
        ax = city_counts.plot(kind="bar", title="Transactions by City")
        ax.set_xlabel("City")
        ax.set_ylabel("Number of Transactions")
        plt.tight_layout()
        plt.savefig(IMAGE_DIR / "eda_city_transactions.png", dpi=150)
        plt.show()
        plt.close()

    # 4. Hourly chart, if transaction_time exists
    if "transaction_time" in transactions.columns:
        parsed_time = pd.to_datetime(
            transactions["transaction_time"].astype("string"),
            errors="coerce"
        )
        hours = parsed_time.dt.hour
        if hours.notna().any():
            hourly_counts = hours.value_counts().sort_index()
            ax = hourly_counts.plot(
                kind="line", marker="o", title="Transactions by Hour"
            )
            ax.set_xlabel("Hour of Day")
            ax.set_ylabel("Number of Transactions")
            ax.set_xticks(range(0, 24, 2))
            plt.tight_layout()
            plt.savefig(IMAGE_DIR / "eda_hourly_transactions.png", dpi=150)
            plt.show()
            plt.close()

    # Export reusable summaries
    status_counts.rename_axis("status").reset_index(
        name="transaction_count"
    ).to_csv(DATA_DIR / "eda_status_summary.csv", index=False)

    if "transaction_type" in transactions.columns:
        transactions.groupby("transaction_type", dropna=False).agg(
            transaction_count=("amount", "size"),
            total_amount=("amount", "sum"),
            average_amount=("amount", "mean")
        ).round(2).reset_index().to_csv(
            DATA_DIR / "eda_transaction_type_summary.csv", index=False
        )

    print("\nEDA completed.")
    print("Charts saved to:", IMAGE_DIR)


if __name__ == "__main__":
    main()
