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
    OR order_date > due_date
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
--===============================================================================================
--=============================== DIM_CUSTOMERS QUALITY ANALYSIS ================================
--===============================================================================================

-- Duplicate Check (Surrogate Key)
SELECT 
    customer_sk,
    COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY customer_sk
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Duplicate Business Key Check
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Duplicate Customer Number Check
SELECT 
    customer_number,
    COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Null Check
SELECT
    SUM(CASE WHEN customer_sk      IS NULL THEN 1 ELSE 0 END) AS customer_sk_null,
    SUM(CASE WHEN customer_id      IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
    SUM(CASE WHEN customer_number  IS NULL THEN 1 ELSE 0 END) AS customer_number_null,
    SUM(CASE WHEN first_name       IS NULL THEN 1 ELSE 0 END) AS first_name_null,
    SUM(CASE WHEN last_name        IS NULL THEN 1 ELSE 0 END) AS last_name_null,
    SUM(CASE WHEN country          IS NULL THEN 1 ELSE 0 END) AS country_null,
    SUM(CASE WHEN marital_status   IS NULL THEN 1 ELSE 0 END) AS marital_status_null,
    SUM(CASE WHEN gender           IS NULL THEN 1 ELSE 0 END) AS gender_null,
    SUM(CASE WHEN created_date     IS NULL THEN 1 ELSE 0 END) AS created_date_null
FROM Gold.dim_customers;

-- Empty String Check
SELECT *
FROM Gold.dim_customers
WHERE 
    TRIM(first_name) = ''
    OR TRIM(last_name) = ''
    OR TRIM(country) = '';

-- Gender Validation
SELECT DISTINCT gender
FROM Gold.dim_customers;

SELECT *
FROM Gold.dim_customers
WHERE gender NOT IN ('Male', 'Female', 'M', 'F');

-- Marital Status Validation
SELECT DISTINCT marital_status
FROM Gold.dim_customers;

SELECT *
FROM Gold.dim_customers
WHERE marital_status NOT IN ('Single', 'Married', 'S', 'M');

-- Future Date Validation
SELECT *
FROM Gold.dim_customers
WHERE created_date > CURRENT_DATE;

-- Name Quality Check
SELECT *
FROM Gold.dim_customers
WHERE 
    first_name LIKE '%[0-9]%'
    OR last_name LIKE '%[0-9]%';

-- Country Standardization Check
SELECT DISTINCT country
FROM Gold.dim_customers
ORDER BY country;

-- Fact Table Orphan Check
SELECT *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
    ON f.customer_sk = c.customer_sk
WHERE c.customer_sk IS NULL;

-- SCD Type-2 Overlap Check (Only if SCD columns exist)
-- Example: effective_date, end_date

/*
SELECT
    customer_id,
    effective_date,
    end_date
FROM Gold.dim_customers
WHERE effective_date > end_date;
*/

-- Record Count Check
SELECT COUNT(*) AS total_customer_records
FROM Gold.dim_customers;

-- Unique Customer Count
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM Gold.dim_customers;