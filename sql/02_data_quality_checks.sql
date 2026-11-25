-- =====================================================================
-- Data quality checks before analysis
-- =====================================================================
USE superstore;

-- 1. Missing values in key columns
SELECT
    SUM(order_id IS NULL)    AS missing_order_id,
    SUM(order_date IS NULL)  AS missing_order_date,
    SUM(sales IS NULL)       AS missing_sales,
    SUM(region IS NULL)      AS missing_region
FROM sales;

-- 2. Impossible values
SELECT COUNT(*) AS bad_rows
FROM sales
WHERE sales <= 0 OR quantity <= 0;

-- 3. Orders shipped before they were placed
SELECT COUNT(*) AS ship_before_order
FROM sales
WHERE ship_date < order_date;

-- 4. Date range covered
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order FROM sales;
