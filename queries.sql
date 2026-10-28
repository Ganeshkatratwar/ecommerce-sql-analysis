-- E-Commerce Sales Analysis (SQL)
-- Tables: products, customers, orders, orderdetails
-- Dialect: MySQL

-- 1. Business overview: orders, customers, products, revenue, average order value
SELECT
    COUNT(*)                         AS total_orders,
    COUNT(DISTINCT customer_id)      AS customers_who_ordered,
    SUM(total_amount)                AS total_revenue,
    ROUND(AVG(total_amount), 0)      AS avg_order_value,
    MIN(order_date)                  AS first_order,
    MAX(order_date)                  AS last_order
FROM orders;

-- 2. Monthly revenue and orders (peak month first)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*)                         AS orders,
    SUM(total_amount)                AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY revenue DESC;

-- 3. Revenue by product with share of total revenue
SELECT
    p.name                                         AS product,
    p.category,
    SUM(od.quantity)                               AS units_sold,
    SUM(od.quantity * od.price_per_unit)           AS revenue,
    ROUND(100.0 * SUM(od.quantity * od.price_per_unit)
          / (SELECT SUM(quantity * price_per_unit) FROM orderdetails), 1) AS revenue_share_pct
FROM orderdetails od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY revenue DESC;

-- 4. Revenue by category with share of total revenue
SELECT
    p.category,
    SUM(od.quantity * od.price_per_unit)           AS revenue,
    ROUND(100.0 * SUM(od.quantity * od.price_per_unit)
          / (SELECT SUM(quantity * price_per_unit) FROM orderdetails), 1) AS revenue_share_pct
FROM orderdetails od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. City performance: customers, orders and revenue by location
SELECT
    c.location                       AS city,
    COUNT(DISTINCT c.customer_id)    AS customers,
    COUNT(o.order_id)                AS orders,
    SUM(o.total_amount)              AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.location
ORDER BY orders DESC, revenue DESC;

-- 6. Repeat customers: how many buyers ordered more than once
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                             AS buying_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)     AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_pct
FROM customer_orders;

-- 7. Top 5 customers by total spend
SELECT
    c.name,
    c.location,
    COUNT(o.order_id)   AS orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.location
ORDER BY total_spent DESC
LIMIT 5;
