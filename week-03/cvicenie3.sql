
CREATE VIEW high_value_customers AS
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, 
    c.customer_name
HAVING 
    SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;

-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA


CREATE VIEW regional_monthly_sales AS
SELECT 
    c.region,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.sales) AS monthly_sales
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.region, 
    DATE_TRUNC('month', o.order_date);

SELECT *
FROM regional_monthly_sales
WHERE region = 'West';

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE VIEW analyst_orders AS
SELECT 
    order_id,
    customer_id,
    product_id,
    sales,
    quantity,
    discount
FROM 
    orders;

SELECT *
FROM analyst_orders;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE INDEX idx_orders_customer_id ON orders(customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE INDEX idx_orders_order_date ON orders(order_date);

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS sum
FROM 
    orders
GROUP BY 
    DATE_TRUNC('month', order_date)
ORDER BY 
    month ASC;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE INDEX idx_orders_region_category ON orders(customer_id, order_date);

SELECT 
    o.*, 
    c.customer_name, 
    c.region
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    c.region = 'West' 
    AND o.order_date >= '2024-01-01';

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE DATABASE retail_sales;
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales DECIMAL(10, 2) NOT NULL,
    profit DECIMAL(10, 2) NOT NULL
);
ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

SELECT *
FROM orders;

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC;
BEGIN
    SELECT SUM(sales) INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník: %, Celkový predaj: %', p_customer_id, v_total_sales;
END;
$$;

CALL get_customer_sales('C001');
--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE OR REPLACE PROCEDURE apply_regional_discount(region_name VARCHAR, discount_rate NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'Zľava % bola úspešne aplikovaná pre región %.', discount_rate, region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);

--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

CREATE OR REPLACE PROCEDURE get_sales_between(start_date DATE, end_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC;
BEGIN
    SELECT SUM(sales) INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Začiatok: %, Koniec: %, Celkový predaj: %', start_date, end_date, v_total_sales;
END;
$$;

CALL get_sales_between('2024-01-01', '2024-03-31');