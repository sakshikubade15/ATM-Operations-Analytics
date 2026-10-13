
-- Project: ATM Operations & Cash Management Analytics
-- Purpose: Validate data quality before analysis.
-- Database: atm_analytics

-- 1. Check the number of records in each table
SELECT 'atms' AS table_name, COUNT(*) AS total_records
FROM atmsss
UNION ALL
SELECT 'transactions', COUNT(*)
FROM transactions
UNION ALL
SELECT 'cash_refills', COUNT(*)
FROM cash_refills
UNION ALL
SELECT 'maintenance', COUNT(*)
FROM maintenance;


-- 2. Check missing important fields in transactions
SELECT
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_transaction_id,
    COUNT(*) FILTER (WHERE atm_id IS NULL) AS missing_atm_id,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS missing_transaction_date,
    COUNT(*) FILTER (WHERE amount IS NULL) AS missing_amount,
    COUNT(*) FILTER (WHERE status IS NULL OR TRIM(status) = '') AS missing_status
FROM transactions;


-- 3. Find duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM transactions
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- 4. Check transaction status values
SELECT
    status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY status
ORDER BY transaction_count DESC;


-- 5. Find failed transactions without a failure reason
SELECT
    transaction_id,
    atm_id,
    transaction_date,
    transaction_type,
    status,
    failure_reason
FROM transactions
WHERE LOWER(TRIM(status)) = 'failed'
  AND (
      failure_reason IS NULL
      OR TRIM(failure_reason) = ''
  );


-- 6. Check for negative transaction amounts
SELECT *
FROM transactions
WHERE amount < 0;


-- 7. Find transactions linked to ATM IDs that do not exist
SELECT t.*
FROM transactions AS t
LEFT JOIN atms AS a
    ON t.atm_id = a.atm_id
WHERE t.atm_id IS NOT NULL
  AND a.atm_id IS NULL;
