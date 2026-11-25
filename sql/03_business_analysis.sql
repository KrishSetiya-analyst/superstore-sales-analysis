-- =====================================================================
-- Superstore Sales Analysis: business questions (MySQL 8)
-- =====================================================================
USE superstore;

-- Q1. Overall KPIs: sales, profit, orders, units, profit margin
SELECT
    ROUND(SUM(sales), 0)                      AS total_sales,
    ROUND(SUM(profit), 0)                     AS total_profit,
    COUNT(DISTINCT order_id)                  AS total_orders,
    SUM(quantity)                             AS units_sold,
    ROUND(SUM(profit) / SUM(sales) * 100, 1)  AS profit_margin_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM sales;

-- Q2. Sales and profit by region, with share of total sales
SELECT
    region,
    ROUND(SUM(sales), 0)  AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS sales_share_pct
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- Q3. Category performance: which category drives sales vs profit?
SELECT
    category,
    ROUND(SUM(sales), 0)  AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS sales_share_pct
FROM sales
GROUP BY category
ORDER BY total_sales DESC;

-- Q4. Loss-making sub-categories (where are we losing money?)
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 0)  AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit
FROM sales
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- Q5. Customer segments
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(sales), 0)        AS total_sales,
    ROUND(SUM(profit), 0)       AS total_profit
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;

-- Q6. Payment modes: how do customers pay?
SELECT
    payment_mode,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 0)     AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS sales_share_pct
FROM sales
GROUP BY payment_mode
ORDER BY total_sales DESC;

-- Q7. Monthly sales trend with month-over-month growth (window function: LAG)
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(sales)  AS total_sales,
        SUM(profit) AS total_profit
    FROM sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    order_month,
    ROUND(total_sales, 0)  AS total_sales,
    ROUND(total_profit, 0) AS total_profit,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY order_month))
          / LAG(total_sales) OVER (ORDER BY order_month) * 100, 1) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- Q8. Year-over-year sales by region
SELECT
    region,
    ROUND(SUM(CASE WHEN YEAR(order_date) = 2019 THEN sales ELSE 0 END), 0) AS sales_2019,
    ROUND(SUM(CASE WHEN YEAR(order_date) = 2020 THEN sales ELSE 0 END), 0) AS sales_2020,
    ROUND((SUM(CASE WHEN YEAR(order_date) = 2020 THEN sales ELSE 0 END)
         - SUM(CASE WHEN YEAR(order_date) = 2019 THEN sales ELSE 0 END))
         / SUM(CASE WHEN YEAR(order_date) = 2019 THEN sales ELSE 0 END) * 100, 1) AS yoy_growth_pct
FROM sales
GROUP BY region
ORDER BY yoy_growth_pct DESC;

-- Q9. Top 3 products by sales in each category (window function: DENSE_RANK)
WITH product_sales AS (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS sales_rank
    FROM sales
    GROUP BY category, product_name
)
SELECT category, sales_rank, product_name, ROUND(total_sales, 0) AS total_sales
FROM product_sales
WHERE sales_rank <= 3
ORDER BY category, sales_rank;

-- Q10. Top 10 customers by sales
SELECT
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 0)     AS total_sales,
    ROUND(SUM(profit), 0)    AS total_profit
FROM sales
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;

-- Q11. Shipping: average days to ship by ship mode
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_days_to_ship
FROM sales
GROUP BY ship_mode
ORDER BY avg_days_to_ship;

-- Q12. Return rate by category
SELECT
    category,
    COUNT(*) AS line_items,
    SUM(returns = 'Yes') AS returned_items,
    ROUND(SUM(returns = 'Yes') * 100 / COUNT(*), 1) AS return_rate_pct
FROM sales
GROUP BY category
ORDER BY return_rate_pct DESC;
