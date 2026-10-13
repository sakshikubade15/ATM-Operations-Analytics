
-- Project: ATM Operations & Cash Management Analytics
-- File: 05_maintenance_analysis.sql
-- Purpose: Analyze ATM maintenance frequency, downtime, and costs.

-- 1. Overall maintenance summary
SELECT
    COUNT(*) AS total_maintenance_records,
    COUNT(DISTINCT atm_id) AS atms_maintained,
    ROUND(SUM(downtime_hours), 2) AS total_downtime_hours,
    ROUND(AVG(downtime_hours), 2) AS average_downtime_hours,
    ROUND(SUM(maintenance_cost), 2) AS total_maintenance_cost,
    ROUND(AVG(maintenance_cost), 2) AS average_maintenance_cost
FROM maintenance;


-- 2. Maintenance activity by component
SELECT
    component,
    COUNT(*) AS maintenance_events,
    ROUND(SUM(downtime_hours), 2) AS total_downtime_hours,
    ROUND(AVG(downtime_hours), 2) AS average_downtime_hours,
    ROUND(SUM(maintenance_cost), 2) AS total_maintenance_cost
FROM maintenance
GROUP BY component
ORDER BY total_downtime_hours DESC;


-- 3. Maintenance activity by ATM
SELECT
    atm_id,
    COUNT(*) AS maintenance_events,
    ROUND(SUM(downtime_hours), 2) AS total_downtime_hours,
    ROUND(AVG(downtime_hours), 2) AS average_downtime_hours,
    ROUND(SUM(maintenance_cost), 2) AS total_maintenance_cost
FROM maintenance
WHERE atm_id IS NOT NULL
GROUP BY atm_id
ORDER BY total_downtime_hours DESC;


-- 4. Monthly maintenance trends
SELECT
    DATE_TRUNC('month', maintenance_date)::date AS maintenance_month,
    COUNT(*) AS maintenance_events,
    ROUND(SUM(downtime_hours), 2) AS total_downtime_hours,
    ROUND(SUM(maintenance_cost), 2) AS total_maintenance_cost
FROM maintenance
GROUP BY DATE_TRUNC('month', maintenance_date)
ORDER BY maintenance_month;


-- 5. Components with the highest average downtime
SELECT
    component,
    COUNT(*) AS maintenance_events,
    ROUND(AVG(downtime_hours), 2) AS average_downtime_hours
FROM maintenance
GROUP BY component
HAVING COUNT(*) >= 10
ORDER BY average_downtime_hours DESC;


-- 6. Find invalid maintenance values
SELECT *
FROM maintenance
WHERE downtime_hours IS NULL
   OR downtime_hours < 0
   OR maintenance_cost IS NULL
   OR maintenance_cost < 0;
