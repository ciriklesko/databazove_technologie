
CREATE DATABASE datacraftinglab_db

CREATE TABLE flourmills_sales (
    sales_id INT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10, 2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10, 2)
);

SELECT * from flourmills_sales;

SELECT 
    product_name, 
    total_amount
FROM 
    flourmills_sales
WHERE 
    total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);


SELECT *
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;

SELECT 
    product_name, 
    total_amount, 
    (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount
FROM 
    flourmills_sales;