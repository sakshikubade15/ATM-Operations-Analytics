
-- Project: ATM Operations & Cash Management Analytics
-- File: 03_atm_performance.sql
-- Purpose: Compare ATM performance and reliability.

-- 1. Total transactions and success rate for each ATM
SELECT
    atm_id,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'successful'
    ) AS successful_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'failed'
    ) AS failed_transactions,
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(TRIM(status)) = 'successful'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate_percent,
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(TRIM(status)) = 'failed'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_percent
FROM transactions
WHERE atm_id IS NOT NULL
GROUP BY atm_id
ORDER BY failure_rate_percent DESC;


-- 2. Identify high-failure ATMs
-- Only include ATMs with at least 50 transactions.
SELECT
    atm_id,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'failed'
    ) AS failed_transactions,
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(TRIM(status)) = 'failed'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_percent
FROM transactions
WHERE atm_id IS NOT NULL
GROUP BY atm_id
HAVING COUNT(*) >= 50
ORDER BY failure_rate_percent DESC;


-- 3. Compare ATM transaction performance by city
SELECT
    a.city,
    COUNT(t.transaction_id) AS total_transactions,
    COUNT(t.transaction_id) FILTER (
        WHERE LOWER(TRIM(t.status)) = 'successful'
    ) AS successful_transactions,
    COUNT(t.transaction_id) FILTER (
        WHERE LOWER(TRIM(t.status)) = 'failed'
    ) AS failed_transactions,
    ROUND(
        COUNT(t.transaction_id) FILTER (
            WHERE LOWER(TRIM(t.status)) = 'successful'
        ) * 100.0 /
        NULLIF(COUNT(t.transaction_id), 0),
        2
    ) AS success_rate_percent
FROM atms AS a
LEFT JOIN transactions AS t
    ON a.atm_id = t.atm_id
GROUP BY a.city
ORDER BY total_transactions DESC;


-- 4. Successful transaction amounts by ATM
SELECT
    atm_id,
    COUNT(*) AS successful_transactions,
    ROUND(SUM(amount), 2) AS total_successful_amount,
    ROUND(AVG(amount), 2) AS average_transaction_amount
FROM transactions
WHERE LOWER(TRIM(status)) = 'successful'
  AND atm_id IS NOT NULL
GROUP BY atm_id
ORDER BY total_successful_amount DESC;


-- 5. Monthly transaction performance
SELECT
    DATE_TRUNC('month', transaction_date)::date AS transaction_month,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'successful'
    ) AS successful_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'failed'
    ) AS failed_transactions,
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(TRIM(status)) = 'failed'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_percent
FROM transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY transaction_month;
