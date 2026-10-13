"""
ATM Operations & Cash Management Analytics
File: 03_anomaly_analysis.py

Purpose:
- Flag unusually high transaction amounts for investigation.
- Identify ATMs with relatively high transaction failure rates.
- Export review files without changing the source data.

Note: Statistical flags are not proof of fraud or ATM malfunction.
"""

from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"

INPUT_FILE = DATA_DIR / "ATM_Analytics_Cleaned.xlsx"
TRANSACTION_FLAGS_FILE = DATA_DIR / "anomaly_transaction_review.csv"
ATM_FLAGS_FILE = DATA_DIR / "anomaly_atm_failure_review.csv"


def find_sheet(sheets, keyword):
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
    transactions = find_sheet(sheets, "transaction")

    if transactions is None:
        raise ValueError(
            f"No transaction sheet found. Available sheets: {list(sheets)}"
        )

    transactions.columns = [
        str(c).strip().lower().replace(" ", "_").replace("-", "_")
        for c in transactions.columns
    ]

    required = {"amount", "status", "atm_id"}
    missing = required - set(transactions.columns)
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    transactions["amount"] = pd.to_numeric(
        transactions["amount"], errors="coerce"
    )
    transactions["status"] = (
        transactions["status"].astype("string").str.strip().str.lower()
    )

    # Analyze successful withdrawals separately because transaction
    # types may have different normal amount ranges.
    if "transaction_type" in transactions.columns:
        withdrawals = transactions[
            (transactions["transaction_type"].astype("string").str.strip().str.lower() == "withdrawal")
            & (transactions["status"] == "successful")
        ].copy()
    else:
        withdrawals = transactions[
            transactions["status"] == "successful"
        ].copy()

    valid_amounts = withdrawals["amount"].dropna()

    if len(valid_amounts) >= 2:
        mean_amount = valid_amounts.mean()
        std_amount = valid_amounts.std()
        threshold = mean_amount + 2 * std_amount

        withdrawals["review_reason"] = ""
        withdrawals.loc[
            withdrawals["amount"] > threshold, "review_reason"
        ] = "Amount above mean plus two standard deviations"

        amount_flags = withdrawals[
            withdrawals["review_reason"] != ""
        ].copy()

        print("\nHIGH-VALUE TRANSACTION REVIEW")
        print("=" * 40)
        print(f"Transactions assessed: {len(valid_amounts):,}")
        print(f"Average amount: {mean_amount:.2f}")
        print(f"Standard deviation: {std_amount:.2f}")
        print(f"Review threshold: {threshold:.2f}")
        print(f"Transactions flagged: {len(amount_flags):,}")

        amount_flags.to_csv(TRANSACTION_FLAGS_FILE, index=False)
        print("Transaction review saved:", TRANSACTION_FLAGS_FILE)
    else:
        print("Not enough valid amounts to calculate a review threshold.")

    # Calculate failure rates by ATM
    transactions["is_failed"] = (
        transactions["status"] == "failed"
    ).astype(int)

    atm_summary = transactions.dropna(subset=["atm_id"]).groupby(
        "atm_id"
    ).agg(
        total_transactions=("is_failed", "size"),
        failed_transactions=("is_failed", "sum")
    ).reset_index()

    atm_summary = atm_summary[
        atm_summary["total_transactions"] >= 50
    ].copy()

    atm_summary["failure_rate_percent"] = (
        atm_summary["failed_transactions"]
        / atm_summary["total_transactions"] * 100
    ).round(2)

    overall_failure_rate = (
        transactions["is_failed"].mean() * 100
        if len(transactions) else 0
    )

    atm_summary["overall_failure_rate_percent"] = round(
        overall_failure_rate, 2
    )
    atm_summary["above_overall_rate"] = (
        atm_summary["failure_rate_percent"] > overall_failure_rate
    )

    atm_summary = atm_summary.sort_values(
        "failure_rate_percent", ascending=False
    )

    atm_summary.to_csv(ATM_FLAGS_FILE, index=False)

    print("\nATM FAILURE-RATE REVIEW")
    print("=" * 40)
    print(f"Overall failure rate: {overall_failure_rate:.2f}%")
    print("ATMs assessed (minimum 50 transactions):", len(atm_summary))
    print("\nHighest failure-rate ATMs:")
    print(atm_summary.head(10).to_string(index=False))
    print("\nATM review saved:", ATM_FLAGS_FILE)


if __name__ == "__main__":
    main()
