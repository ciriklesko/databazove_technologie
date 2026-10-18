-- Active: 1790526779313@@127.0.0.1@5432@superstore

WITH customer_profit AS (
    SELECT
        c.region,
        c.customer_name,
        ROUND(SUM(o.profit), 2) AS total_profit
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.region, c.customer_id, c.customer_name
)
SELECT
    region,
    customer_name,
    total_profit,
    RANK() OVER (
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_rank,
    DENSE_RANK() OVER (
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_dense_rank
FROM customer_profit
ORDER BY region, total_profit DESC, customer_name;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH customer_sales AS (
    SELECT
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    ROUND(total_sales, 2) AS total_sales,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM customer_sales
ORDER BY total_sales DESC;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    ROUND(monthly_sales, 2) AS monthly_sales,
    LAG(ROUND(monthly_sales, 2), 1) OVER (ORDER BY month) AS prev_month_sales,
    LEAD(ROUND(monthly_sales, 2), 1) OVER (ORDER BY month) AS next_month_sales
FROM monthly
ORDER BY month;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    ROUND(product_sales, 2) AS product_sales,
    ROUND(SUM(product_sales) OVER (PARTITION BY category), 2) AS category_total,
    ROUND(
        product_sales * 100.0 / SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
FROM product_sales
ORDER BY category, pct_of_category DESC;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
with_prev AS (
    SELECT
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly
)
SELECT
    month,
    ROUND(monthly_sales, 2) AS monthly_sales,
    ROUND(prev_month_sales, 2) AS prev_month_sales,
    ROUND(monthly_sales - prev_month_sales, 2) AS sales_change,
    ROUND((monthly_sales - prev_month_sales) / prev_month_sales * 100, 2) AS growth_percentage
FROM with_prev
ORDER BY month ASC;