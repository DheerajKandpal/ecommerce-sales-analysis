-- ============================================================
-- E-Commerce Sales Analysis
-- File 02: Revenue & Sales Trends
-- Author: Dheeraj Kandpal
-- Business Question: How is revenue trending over time?
-- ============================================================

USE ecommerce_db;

-- -----------------------------------------------
-- Q1. Total revenue, profit, and orders overall
-- -----------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)          AS total_orders,
    SUM(oi.sales)                       AS total_revenue,
    SUM(oi.profit)                      AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS profit_margin_pct,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- -----------------------------------------------
-- Q2. Monthly revenue trend (year-over-year)
-- -----------------------------------------------
SELECT
    YEAR(o.order_date)                  AS yr,
    MONTH(o.order_date)                 AS mo,
    DATE_FORMAT(o.order_date, '%b %Y')  AS month_label,
    COUNT(DISTINCT o.order_id)          AS orders_count,
    ROUND(SUM(oi.sales), 2)             AS monthly_revenue,
    ROUND(SUM(oi.profit), 2)            AS monthly_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY yr, mo, month_label
ORDER BY yr, mo;


-- -----------------------------------------------
-- Q3. Revenue by region
-- -----------------------------------------------
SELECT
    o.region,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Q4. Revenue by shipping mode
-- -----------------------------------------------
SELECT
    o.ship_mode,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(AVG(DATEDIFF(
        o.ship_date, o.order_date)), 1) AS avg_ship_days
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.ship_mode
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Q5. Year-over-year revenue growth
-- -----------------------------------------------
WITH yearly AS (
    SELECT
        YEAR(o.order_date)      AS yr,
        ROUND(SUM(oi.sales), 2) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY yr
)
SELECT
    yr,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY yr)   AS prev_year_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY yr))
        / LAG(total_revenue) OVER (ORDER BY yr) * 100
    , 2)                                    AS yoy_growth_pct
FROM yearly
ORDER BY yr;


-- -----------------------------------------------
-- Q6. Running cumulative revenue by month
-- -----------------------------------------------
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS yr_mo,
        ROUND(SUM(oi.sales), 2)            AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY yr_mo
)
SELECT
    yr_mo,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (
        ORDER BY yr_mo
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS cumulative_revenue
FROM monthly
ORDER BY yr_mo;
