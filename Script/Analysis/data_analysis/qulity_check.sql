--===============================================================================================
--=============================== FACT_SALES QULITY ANALYSIS ====================================
--===============================================================================================
-- Dupicate check 
SELECT 
    sales_sk ,
    count(*) unique_count
FROM Gold.fact_sales 
    GROUP BY sales_sk
    HAVING COUNT(*) > 1
    ORDER BY unique_count DESC ;

-- Null check 
SELECT
    SUM(CASE WHEN sales_sk       IS NULL THEN 1 ELSE 0 END ) AS sales_sk_null,
    SUM(CASE WHEN product_sk     IS NULL THEN 1 ELSE 0 END ) AS product_sk_null,
    SUM(CASE WHEN customer_sk    IS NULL THEN 1 ELSE 0 END ) AS customer_sk_null,
    SUM(CASE WHEN order_number   IS NULL THEN 1 ELSE 0 END ) AS order_number_null,
    SUM(CASE WHEN order_date     IS NULL THEN 1 ELSE 0 END ) AS order_date_null,
    SUM(CASE WHEN shipping_date  IS NULL THEN 1 ELSE 0 END ) AS shipping_date_null,
    SUM(CASE WHEN due_date       IS NULL THEN 1 ELSE 0 END ) AS due_date_null,
    SUM(CASE WHEN sales_amount   IS NULL THEN 1 ELSE 0 END ) AS sales_amount_null,
    SUM(CASE WHEN quantity_sold  IS NULL THEN 1 ELSE 0 END ) AS quantity_sold_null,
    SUM(CASE WHEN unit_price     IS NULL THEN 1 ELSE 0 END ) AS unit_pric_null
FROM Gold.fact_sales;

--Business Rule 
SELECT *
FROM Gold.fact_sales
WHERE sales_amount <= 0
   OR quantity_sold <= 0
   OR unit_price <= 0;

-- Revenue Validation 
SELECT
    sales_sk,
    sales_amount,
    quantity_sold,
    unit_price,
    (quantity_sold * unit_price) AS calculated_sales
FROM Gold.fact_sales
WHERE sales_amount != (quantity_sold * unit_price);

-- Date Validation
SELECT 
order_date,
shipping_date,
due_date 
FROM Gold.fact_sales 
WHERE 
    order_date > shipping_date
    OR order_date > shipping_date
    OR shipping_date > due_date ;

-- Product Orphan Check 
SELECT *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_products p
    ON f.product_sk = p.product_sk
WHERE p.product_sk IS NULL;

-- Customer Orphan Check
SELECT *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
    ON f.customer_sk = c.customer_sk
WHERE c.customer_sk IS NULL;

-- Granularity Check
SELECT
    order_number,
    product_sk,
    COUNT(*) AS cnt
FROM Gold.fact_sales
GROUP BY
    order_number,
    product_sk
HAVING COUNT(*) > 1;

--===============================================================================================
--=============================== DIM_CUSTOMERS QULITY ANALYSIS =================================
--===============================================================================================