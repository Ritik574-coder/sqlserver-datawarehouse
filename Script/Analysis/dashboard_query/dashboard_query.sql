-- Customer Order Volume Analysis
SELECT 
    s.customer_sk AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(*) AS total_orders
FROM Gold.fact_sales AS s
INNER JOIN Gold.dim_customers AS c
    ON s.customer_sk = c.customer_sk
GROUP BY 
    s.customer_sk,
    CONCAT(c.first_name, ' ', c.last_name)
ORDER BY total_orders DESC;

-- Customer Sales Performance Analysis
SELECT 
    s.customer_sk AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(*) AS total_orders,
    SUM(s.sales_amount) AS total_sales
FROM Gold.fact_sales AS s
INNER JOIN Gold.dim_customers AS c
    ON s.customer_sk = c.customer_sk
GROUP BY 
    s.customer_sk,
    CONCAT(c.first_name, ' ', c.last_name)
ORDER BY total_sales DESC, total_orders DESC;

-- Monthly Share of Total Revenue
SELECT 
    YEAR(shipping_date) AS sales_year,
    MONTH(shipping_date) AS sales_month,
    SUM(sales_amount) AS monthly_sales,

    ROUND(
        SUM(sales_amount) * 100.0
        / SUM(SUM(sales_amount)) OVER(), 2
    ) AS total_sales_contribution_pct
FROM Gold.fact_sales
GROUP BY 
    YEAR(shipping_date),
    MONTH(shipping_date)
ORDER BY 
    sales_year,
    sales_month;

-- Monthly Sales Contribution Within Each Year
SELECT 
    YEAR(shipping_date) AS sales_year,
    MONTH(shipping_date) AS sales_month,
    SUM(sales_amount) AS monthly_sales,

    ROUND(
        SUM(sales_amount) * 100.0
        / SUM(SUM(sales_amount)) OVER(
            PARTITION BY YEAR(shipping_date)
        ), 2
    ) AS yearly_sales_contribution_pct
FROM Gold.fact_sales
GROUP BY 
    YEAR(shipping_date),
    MONTH(shipping_date)
ORDER BY 
    sales_year,
    sales_month;

-- Yearly Sales Contribution to Total Sales
SELECT 
    YEAR(shipping_date) AS sales_year,
    SUM(sales_amount) AS yearly_sales,

    ROUND(
        SUM(sales_amount) * 100.0
        / SUM(SUM(sales_amount)) OVER(), 2
    ) AS total_sales_contribution_pct
FROM Gold.fact_sales
GROUP BY 
    YEAR(shipping_date)
ORDER BY sales_year;


-- Sales Amount Summary Analysis
SELECT 
    SUM(sales_amount) AS total_sales_amount,
    AVG(sales_amount) AS average_sales_amount,
    MIN(sales_amount) AS minimum_sales_amount,
    MAX(sales_amount) AS maximum_sales_amount
FROM Gold.fact_sales;

-- Quantity Sold Summary Analysis
SELECT 
    SUM(quantity_sold) AS total_qt_sold,
    AVG(quantity_sold) AS avg_qt_sold,
    MIN(quantity_sold) AS min_qt_sold,
    MAX(quantity_sold) AS max_qt_sold
FROM Gold.fact_sales ; 

-- Unit Price Summary Analysis
SELECT 
    SUM(unit_price) AS total_unit_price,
    AVG(unit_price) AS avg_unit_price,
    MIN(unit_price) AS min_unit_price,
    MAX(unit_price) AS max_unit_price
FROM Gold.fact_sales ; 


SELECT 
    AVG(DATEDIFF(day, order_date, shipping_date)) AS avg_order_to_shipping_days,
    MAX(DATEDIFF(day, order_date, shipping_date)) AS max_order_to_shipping_days,
    MIN(DATEDIFF(day, order_date, shipping_date)) AS max_order_to_shipping_days
FROM Gold.fact_sales;


SELECT * FROM Gold.fact_sales
WHERE order_date < shipping_date AND shipping_date < due_date;

SELECT * FROM gold.fact_sales ; 