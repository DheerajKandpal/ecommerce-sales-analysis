-- ============================================================
-- E-Commerce Sales Analysis
-- File 04: Customer Segmentation & Behaviour
-- Author: Dheeraj Kandpal
-- Business Question: Who are our most valuable customers?
-- ============================================================

USE ecommerce_db;

-- -----------------------------------------------
-- Q1. Revenue per customer with order frequency
-- -----------------------------------------------
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    ROUND(SUM(oi.sales), 2)                 AS total_spent,
    ROUND(SUM(oi.profit), 2)                AS total_profit_generated,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT o.order_id), 2)    AS avg_order_value,
    MIN(o.order_date)                       AS first_order,
    MAX(o.order_date)                       AS last_order
FROM customers c
JOIN orders o    ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.city, c.state
ORDER BY total_spent DESC;


-- -----------------------------------------------
-- Q2. Revenue by customer segment
-- -----------------------------------------------
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)           AS customer_count,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    ROUND(SUM(oi.sales), 2)                 AS total_revenue,
    ROUND(SUM(oi.profit), 2)                AS total_profit,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.segment
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Q3. RFM Segmentation
--     Recency   = days since last order
--     Frequency = number of orders
--     Monetary  = total spend
-- -----------------------------------------------
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.segment,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(o.order_date)
        )                                   AS recency_days,
        COUNT(DISTINCT o.order_id)          AS frequency,
        ROUND(SUM(oi.sales), 2)             AS monetary
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.segment
),
rfm_scores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days ASC)  AS r_score,  -- lower recency = better
        NTILE(4) OVER (ORDER BY frequency    DESC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary     DESC) AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    customer_name,
    segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)          AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 8  THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 6  THEN 'Potential Loyalists'
        WHEN r_score <= 2                         THEN 'At Risk'
        ELSE 'Need Attention'
    END                                    AS rfm_segment
FROM rfm_scores
ORDER BY rfm_total DESC;


-- -----------------------------------------------
-- Q4. Top 3 customers per region by revenue
-- -----------------------------------------------
WITH regional_rank AS (
    SELECT
        o.region,
        c.customer_name,
        ROUND(SUM(oi.sales), 2)             AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY o.region
            ORDER BY SUM(oi.sales) DESC
        )                                   AS rn
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    GROUP BY o.region, c.customer_id, c.customer_name
)
SELECT region, customer_name, total_revenue, rn AS rank_in_region
FROM regional_rank
WHERE rn <= 3
ORDER BY region, rn;


-- -----------------------------------------------
-- Q5. New vs returning customers per year
-- -----------------------------------------------
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_date
    FROM orders
    GROUP BY customer_id
)
SELECT
    YEAR(o.order_date)              AS yr,
    COUNT(DISTINCT CASE
        WHEN YEAR(o.order_date) = YEAR(fo.first_date)
        THEN o.customer_id END)     AS new_customers,
    COUNT(DISTINCT CASE
        WHEN YEAR(o.order_date) > YEAR(fo.first_date)
        THEN o.customer_id END)     AS returning_customers
FROM orders o
JOIN first_order fo ON o.customer_id = fo.customer_id
GROUP BY yr
ORDER BY yr;
