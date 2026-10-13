
-- Project: ATM Operations & Cash Management Analytics
-- File: 02_transaction_analysis.sql
-- Purpose: Analyze ATM transaction performance.

-- 1. Total transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;


-- 2. Successful vs failed transactions
SELECT
    TRIM(status) AS transaction_status,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM transactions), 0),
        2
    ) AS percentage
FROM transactions
GROUP BY TRIM(status)
ORDER BY total_transactions DESC;


-- 3. Overall transaction success rate
SELECT
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
    ) AS success_rate_percent
FROM transactions;


-- 4. Transaction volume by transaction type
SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount), 2) AS average_amount,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_transactions DESC;


-- 5. Failure reasons
SELECT
    COALESCE(
        NULLIF(TRIM(failure_reason), ''),
        'Missing reason'
    ) AS failure_reason,
    COUNT(*) AS failed_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*)
             FROM transactions
             WHERE LOWER(TRIM(status)) = 'failed'),
            0
        ),
        2
    ) AS percentage_of_failures
FROM transactions
WHERE LOWER(TRIM(status)) = 'failed'
GROUP BY COALESCE(
    NULLIF(TRIM(failure_reason), ''),
    'Missing reason'
)
ORDER BY failed_transactions DESC;


-- 6. Daily transaction trends
SELECT
    transaction_date,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'successful'
    ) AS successful_transactions,
    COUNT(*) FILTER (
        WHERE LOWER(TRIM(status)) = 'failed'
    ) AS failed_transactions
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;


-- 7. Hourly transaction volume
SELECT
    EXTRACT(HOUR FROM transaction_time) AS transaction_hour,
    COUNT(*) AS total_transactions
FROM transactions
WHERE transaction_time IS NOT NULL
GROUP BY EXTRACT(HOUR FROM transaction_time)
ORDER BY total_transactions DESC;


-- 8. Successful transaction amount
SELECT
    COUNT(*) AS successful_transactions,
    ROUND(SUM(amount), 2) AS total_successful_amount,
    ROUND(AVG(amount), 2) AS average_successful_amount,
    MIN(amount) AS minimum_successful_amount,
    MAX(amount) AS maximum_successful_amount
FROM transactions
WHERE LOWER(TRIM(status)) = 'successful';
