# ATM Operations & Cash Management Analytics

## Project Overview

This project analyzes ATM transaction performance, cash refill activity, ATM reliability, and maintenance operations using SQL and Python.

The goal is to turn raw operational data into meaningful insights that can help banking operations teams monitor transaction failures, identify ATMs requiring investigation, understand cash refill patterns, and prioritize maintenance.

**Dataset disclosure:** This project uses synthetic data for educational and portfolio purposes. The data does not represent actual bank operations or real customer transactions.

## Business Objectives

- Measure transaction success and failure rates.
- Identify ATMs with comparatively high failure rates.
- Analyze transaction volumes by type, city, date, and hour.
- Evaluate cash refill frequency and amounts.
- Compare maintenance downtime across ATMs and components.
- Flag unusual transaction amounts for further investigation.
- Develop evidence-based operational recommendations.

## Tools and Technologies

- **PostgreSQL:** Data validation, joins, aggregations, KPI calculations, and business analysis.
- **Python:** Data cleaning, exploratory data analysis, and anomaly screening.
- **Pandas:** Data manipulation and data-quality checks.
- **NumPy:** Numerical analysis.
- **Matplotlib:** Data visualization.
- **Excel:** Dataset review and reporting preparation.
- **Power BI:** Planned for a future interactive dashboard; a `.pbix` report has not yet been completed.

## Dataset Overview

The project covers four operational data areas:

| Dataset | Purpose |
|---|---|
| ATMs | ATM identifiers and location information |
| Transactions | Transaction type, amount, status, date, time, and failure reason |
| Cash Refills | Cash replenishment events and amounts |
| Maintenance | Maintenance events, components, downtime, and costs |

The dataset includes 10,000 transaction records, 100 ATMs, 4,344 cash refill records, and 514 maintenance records.

## Project Workflow

1. Reviewed the source data and its structure.
2. Used PostgreSQL to validate records and analyze business performance.
3. Created SQL queries for transactions, ATM reliability, cash refills, and maintenance.
4. Used Python and Pandas to standardize column names, trim text values, and assess data quality.
5. Conducted exploratory data analysis and generated charts.
6. Applied statistical screening to flag unusual transaction amounts.
7. Prepared findings and recommendations for operational decision-making.

## Key Findings

- **Transaction success rate:** 94.05% of 10,000 transactions were successful.
- **Failed transactions:** 595 transactions were recorded as failed.
- **Transaction activity:** Pune recorded the highest transaction volume, with 2,435 transactions.
- **Peak usage:** 6 PM was the busiest hour in the analyzed transaction data.
- **Cash replenishment:** 4,344 refill records represented ₹511,650,000 in recorded cash replenishment.
- **Maintenance downtime:** The maintenance dataset recorded 3,141.6 downtime hours.
- **Component-level downtime:** Card Reader maintenance had the highest aggregate downtime at 556.1 hours.
- **ATM reliability:** Some ATMs had higher failure rates than the overall dataset, warranting further investigation.

These findings describe the synthetic dataset and should not be interpreted as real-world banking statistics.

## Business Recommendations

1. Investigate ATMs with elevated failure rates using transaction logs, network records, and maintenance history.
2. Review staffing, cash replenishment planning, and support coverage around peak transaction hours.
3. Investigate components with high aggregate downtime to identify potential maintenance priorities.
4. Monitor transaction failures and failure reasons regularly.
5. Review statistical outliers before taking action; an unusually large transaction is not automatically fraudulent.
6. Improve data quality by investigating duplicate identifiers, missing failure reasons, and incomplete ATM references.

## Repository Structure

```text
ATM-Operations-Analytics/
├── data/
│   ├── ATM_Operations_Cash_Management_Analytics (3).xlsx
│   ├── ATM_Analytics_PowerBI_Ready.xlsx
│   ├── ATM_Analytics_Cleaned.xlsx
│   └── data_quality_report.csv
├── sql/
│   ├── 01_data_validation.sql
│   ├── 02_transaction_analysis.sql
│   ├── 03_atm_performance.sql
│   ├── 04_cash_refill_analysis.sql
│   └── 05_maintenance_analysis.sql
├── python/
│   ├── 01_data_cleaning.py
│   ├── 02_exploratory_data_analysis.py
│   ├── 03_anomaly_analysis.py
│   └── ATM_Data_Cleaning.ipynb
├── power-bi/
├── images/
└── README.md
```

## How to Run

### PostgreSQL

1. Create or connect to the `atm_analytics` database.
2. Ensure the tables `atms`, `transactions`, `cash_refills`, and `maintenance` exist.
3. Open the SQL files in pgAdmin's Query Tool.
4. Execute the scripts against the database.

### Python

Install the required libraries:

```bash
python -m pip install pandas openpyxl matplotlib numpy
```

Run the scripts from the project root:

```bash
python python/01_data_cleaning.py
python python/02_exploratory_data_analysis.py
python python/03_anomaly_analysis.py
```

Run the cleaning script first because the later scripts use its cleaned workbook.

## Limitations

- The data is synthetic and does not represent a real bank.
- Statistical anomaly flags indicate records for review, not confirmed fraud.
- Elevated ATM failure rates do not establish the cause of failures.
- Cash refill totals should not be compared directly with withdrawals to infer surplus cash without matching the relevant time periods and accounting scope.
- The interactive Power BI dashboard remains future work.

## Author

**Sakshi Kubade**ss

B.Tech Computer Science (Cyber Security) | Aspiring Data Analyst

Skills demonstrated: SQL, PostgreSQL, Python, Pandas, Excel, data cleaning, exploratory data analysis, KPI reporting, and business analysis.