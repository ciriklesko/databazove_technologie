-- Active: 1790526779313@@127.0.0.1@5432@retail
CREATE DATABASE retail;

CREATE TABLE retail_sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price DECIMAL(10, 2),
    customer_id INT,
    country VARCHAR(100)
);

SELECT *
FROM retail_sales;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    quantity * unit_price AS revenue,
    SUM(quantity * unit_price) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

SELECT 
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER (
            PARTITION BY stock_code, country
            ORDER BY invoice_date
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ), 2
    ) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH unique_orders AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        invoice_date::date AS invoice_date
    FROM retail_sales
),
orders_with_next AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date) OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date, invoice_no
        ) AS next_invoice_date
    FROM unique_orders
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date - invoice_date AS days_to_next_invoice
FROM orders_with_next
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

WITH price_history AS (
    SELECT
        stock_code,
        invoice_no,
        invoice_date,
        LAG(unit_price) OVER (
            PARTITION BY stock_code
            ORDER BY invoice_date, invoice_no
        ) AS previous_price,
        unit_price AS current_price
    FROM retail_sales
)
SELECT
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    current_price - previous_price AS price_difference
FROM price_history
WHERE previous_price IS NOT NULL
  AND current_price <> previous_price
ORDER BY invoice_date ASC, invoice_no;