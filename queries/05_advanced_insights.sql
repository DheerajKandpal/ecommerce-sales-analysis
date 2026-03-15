-- ============================================================
-- E-Commerce Sales Analysis
-- File 05: Advanced Insights
-- Author: Dheeraj Kandpal
-- Business Question: Hidden patterns — what should the business do next?
-- ============================================================

USE ecommerce_db;

-- -----------------------------------------------
-- Q1. Month-over-month revenue change per region
-- -----------------------------------------------
WITH monthly_regional AS (
    SELECT
        o.region,
        DATE_FORMAT(o.order_date, '%Y-%m')      AS yr_mo,
        ROUND(SUM(oi.sales), 2)                 AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.region, yr_mo
)
SELECT
    region,
    yr_mo,
    revenue,
    LAG(revenue) OVER (
        PARTITION BY region ORDER BY yr_mo
    )                                           AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (
            PARTITION BY region ORDER BY yr_mo)
        ) / NULLIF(LAG(revenue) OVER (
            PARTITION BY region ORDER BY yr_mo), 0) * 100
    , 2)                                        AS mom_growth_pct
FROM monthly_regional
ORDER BY region, yr_mo;


-- -----------------------------------------------
-- Q2. Average days to ship by region and ship mode
-- -----------------------------------------------
SELECT
    o.region,
    o.ship_mode,
    COUNT(o.order_id)                           AS orders,
    ROUND(AVG(DATEDIFF(
        o.ship_date, o.order_date)), 1)         AS avg_days_to_ship,
    MIN(DATEDIFF(o.ship_date, o.order_date))    AS min_days,
    MAX(DATEDIFF(o.ship_date, o.order_date))    AS max_days
FROM orders o
GROUP BY o.region, o.ship_mode
ORDER BY o.region, avg_days_to_ship;


-- -----------------------------------------------
-- Q3. Orders and revenue by day of week
--     (Which days do customers buy most?)
-- -----------------------------------------------
SELECT
    DAYNAME(o.order_date)                       AS day_of_week,
    DAYOFWEEK(o.order_date)                     AS day_num,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(SUM(oi.sales), 2)                     AS total_revenue,
    ROUND(AVG(oi.sales), 2)                     AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY day_of_week, day_num
ORDER BY day_num;


-- -----------------------------------------------
-- Q4. Quarterly performance summary with ranking
-- -----------------------------------------------
WITH quarterly AS (
    SELECT
        YEAR(o.order_date)                      AS yr,
        QUARTER(o.order_date)                   AS qtr,
        CONCAT('Q', QUARTER(o.order_date),
               ' ', YEAR(o.order_date))         AS quarter_label,
        ROUND(SUM(oi.sales), 2)                 AS revenue,
        ROUND(SUM(oi.profit), 2)                AS profit,
        COUNT(DISTINCT o.order_id)              AS orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY yr, qtr, quarter_label
)
SELECT
    quarter_label,
    revenue,
    profit,
    orders,
    ROUND(profit / revenue * 100, 2)            AS margin_pct,
    RANK() OVER (ORDER BY revenue DESC)         AS revenue_rank
FROM quarterly
ORDER BY yr, qtr;


-- -----------------------------------------------
-- Q5. Customer lifetime value (CLV) estimate
--     CLV = avg order value × purchase frequency × customer lifespan (months)
-- -----------------------------------------------
WITH clv_base AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.segment,
        COUNT(DISTINCT o.order_id)              AS frequency,
        ROUND(SUM(oi.sales), 2)                 AS total_revenue,
        ROUND(SUM(oi.sales) /
              COUNT(DISTINCT o.order_id), 2)    AS avg_order_value,
        TIMESTAMPDIFF(MONTH,
            MIN(o.order_date),
            MAX(o.order_date)) + 1              AS lifespan_months
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.segment
)
SELECT
    customer_id,
    customer_name,
    segment,
    frequency,
    avg_order_value,
    lifespan_months,
    ROUND(avg_order_value * frequency, 2)       AS estimated_clv,
    NTILE(4) OVER (
        ORDER BY avg_order_value * frequency DESC
    )                                           AS clv_tier   -- 1 = top 25%
FROM clv_base
ORDER BY estimated_clv DESC;


-- -----------------------------------------------
-- Q6. Executive summary — all KPIs in one query
-- -----------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)              AS total_orders,
    COUNT(DISTINCT o.customer_id)           AS unique_customers,
    COUNT(DISTINCT p.product_id)            AS products_sold,
    ROUND(SUM(oi.sales), 2)                 AS gross_revenue,
    ROUND(SUM(oi.profit), 2)                AS gross_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)           AS overall_margin_pct,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT o.order_id), 2)    AS avg_order_value,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT o.customer_id), 2) AS revenue_per_customer
FROM orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id;
