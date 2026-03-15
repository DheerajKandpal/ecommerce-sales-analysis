-- ============================================================
-- E-Commerce Sales Analysis
-- File 03: Product Performance
-- Author: Dheeraj Kandpal
-- Business Question: Which products and categories drive the most value?
-- ============================================================

USE ecommerce_db;

-- -----------------------------------------------
-- Q1. Top 10 products by revenue
-- -----------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    SUM(oi.quantity)                    AS units_sold,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS margin_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
ORDER BY total_revenue DESC
LIMIT 10;


-- -----------------------------------------------
-- Q2. Category-wise sales and profit breakdown
-- -----------------------------------------------
SELECT
    p.category,
    COUNT(DISTINCT oi.item_id)          AS line_items,
    SUM(oi.quantity)                    AS units_sold,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS margin_pct,
    ROUND(SUM(oi.sales) /
          (SELECT SUM(sales) FROM order_items) * 100
    , 2)                                AS revenue_share_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Q3. Sub-category performance with profit ranking
-- -----------------------------------------------
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS margin_pct,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.profit) DESC
    )                                   AS profit_rank_in_category
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, profit_rank_in_category;


-- -----------------------------------------------
-- Q4. Products with negative or very low profit
--     (discount eating into margin)
-- -----------------------------------------------
SELECT
    p.product_name,
    p.category,
    ROUND(AVG(oi.discount) * 100, 1)    AS avg_discount_pct,
    ROUND(SUM(oi.sales), 2)             AS total_revenue,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) /
          SUM(oi.sales) * 100, 2)       AS margin_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING margin_pct < 15
ORDER BY margin_pct ASC;


-- -----------------------------------------------
-- Q5. Best selling product per category (window fn)
-- -----------------------------------------------
WITH ranked AS (
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(oi.sales), 2) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.sales) DESC
        ) AS rn
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_name, total_revenue
FROM ranked
WHERE rn = 1;


-- -----------------------------------------------
-- Q6. Impact of discount on profit margin
-- -----------------------------------------------
SELECT
    CASE
        WHEN oi.discount = 0         THEN 'No Discount'
        WHEN oi.discount <= 0.05     THEN '1–5%'
        WHEN oi.discount <= 0.10     THEN '6–10%'
        WHEN oi.discount <= 0.20     THEN '11–20%'
        ELSE 'Above 20%'
    END                                 AS discount_band,
    COUNT(*)                            AS orders,
    ROUND(AVG(oi.profit /
              NULLIF(oi.sales, 0) * 100), 2) AS avg_margin_pct,
    ROUND(SUM(oi.profit), 2)            AS total_profit
FROM order_items oi
GROUP BY discount_band
ORDER BY avg_margin_pct DESC;
