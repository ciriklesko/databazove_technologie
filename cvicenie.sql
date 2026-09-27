-- Active: 1790526779313@@127.0.0.1@5432@superstore

SELECT * FROM customers;
CREATE DATABASE superstore;
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10, 2),
    quantity INTEGER,
    discount DECIMAL(10, 2),
    profit DECIMAL(10, 2)
);

SELECT 
    o.order_id,
    c.customer_name,
    o.sales
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.sales > 500
ORDER BY 
    o.sales DESC;

SELECT 
    o.order_id,
    c.customer_name,
    p.category,
    o.sales
FROM 
    orders o
INNER JOIN 
    customers c ON o.customer_id = c.customer_id
INNER JOIN 
    products p ON o.product_id = p.product_id;

SELECT 
    c.region,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.region;

SELECT 
    p.product_name,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM 
    products p
LEFT JOIN 
    orders o ON p.product_id = o.product_id
GROUP BY 
    p.product_id, 
    p.product_name;

SELECT 
    c.customer_name,
    o.order_id,
    o.sales
FROM 
    customers c
FULL OUTER JOIN 
    orders o ON c.customer_id = o.customer_id;