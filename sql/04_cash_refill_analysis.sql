
-- Project: ATM Operations & Cash Management Analytics
-- File: 04_cash_refill_analysis.sql
-- Purpose: Analyze cash refill activity and ATM cash management.

-- 1. Overall cash refill summary
SELECT
    COUNT(*) AS total_refill_records,
    COUNT(DISTINCT atm_id) AS atms_refilled,
    ROUND(SUM(amount), 2) AS total_cash_refilled,
    ROUND(AVG(amount), 2) AS average_refill_amount,
    MIN(amount) AS minimum_refill_amount,
    MAX(amount) AS maximum_refill_amount
FROM cash_refills;


-- 2. Cash refill activity by ATM
SELECT
    atm_id,
    COUNT(*) AS total_refills,
    ROUND(SUM(amount), 2) AS total_cash_refilled,
    ROUND(AVG(amount), 2) AS average_refill_amount
FROM cash_refills
WHERE atm_id IS NOT NULL
GROUP BY atm_id
ORDER BY total_cash_refilled DESC;


-- 3. Monthly cash refill trends
SELECT
    DATE_TRUNC('month', refill_date)::date AS refill_month,
    COUNT(*) AS total_refills,
    ROUND(SUM(amount), 2) AS total_cash_refilled,
    ROUND(AVG(amount), 2) AS average_refill_amount
FROM cash_refills
GROUP BY DATE_TRUNC('month', refill_date)
ORDER BY refill_month;


-- 4. Cash refill activity by city
SELECT
    a.city,
    COUNT(cr.atm_id) AS total_refills,
    ROUND(SUM(cr.amount), 2) AS total_cash_refilled,
    ROUND(AVG(cr.amount), 2) AS average_refill_amount
FROM atms AS a
JOIN cash_refills AS cr
    ON a.atm_id = cr.atm_id
GROUP BY a.city
ORDER BY total_cash_refilled DESC;


-- 5. Find ATMs with the highest refill frequency
SELECT
    atm_id,
    COUNT(*) AS total_refills,
    ROUND(SUM(amount), 2) AS total_cash_refilled
FROM cash_refills
GROUP BY atm_id
HAVING COUNT(*) >= 10
ORDER BY total_refills DESC;


-- 6. Check for unusual or invalid refill amounts
SELECT *
FROM cash_refills
WHERE amount IS NULL
   OR amount <= 0;
