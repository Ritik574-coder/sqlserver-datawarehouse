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
    customer_key,
    COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Null Check
SELECT
    SUM(CASE WHEN customer_sk      IS NULL THEN 1 ELSE 0 END) AS customer_sk_null,
    SUM(CASE WHEN customer_id      IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
    SUM(CASE WHEN customer_key  IS NULL THEN 1 ELSE 0 END) AS customer_key_null,
    SUM(CASE WHEN first_name       IS NULL THEN 1 ELSE 0 END) AS first_name_null,
    SUM(CASE WHEN last_name        IS NULL THEN 1 ELSE 0 END) AS last_name_null,
    SUM(CASE WHEN country          IS NULL THEN 1 ELSE 0 END) AS country_null,
    SUM(CASE WHEN marital_status   IS NULL THEN 1 ELSE 0 END) AS marital_status_null,
    SUM(CASE WHEN gender           IS NULL THEN 1 ELSE 0 END) AS gender_null,
    SUM(CASE WHEN customer_create_date     IS NULL THEN 1 ELSE 0 END) AS created_date_null
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
WHERE gender NOT IN ('Male', 'Female', 'Unknown');

-- Marital Status Validation
SELECT DISTINCT marital_status
FROM Gold.dim_customers;

SELECT *
FROM Gold.dim_customers
WHERE marital_status NOT IN ('Single', 'Married');

-- Future Date Validation
SELECT *
FROM Gold.dim_customers
WHERE customer_create_date > GETDATE();

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

-- Record Count Check
SELECT COUNT(*) AS total_customer_records
FROM Gold.dim_customers;

-- Unique Customer Count
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM Gold.dim_customers;

--===============================================================================================
--=============================== DIM_PRODUCTS QUALITY ANALYSIS ================================
--===============================================================================================

-- Duplicate Check (Surrogate Key)
SELECT 
    product_sk,
    COUNT(*) AS duplicate_count
FROM Gold.dim_products
GROUP BY product_sk
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Duplicate Business Key Check
SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM Gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Null Check
SELECT
    SUM(CASE WHEN product_sk         IS NULL THEN 1 ELSE 0 END) AS product_sk_null,
    SUM(CASE WHEN product_id         IS NULL THEN 1 ELSE 0 END) AS product_id_null,
    SUM(CASE WHEN category_id        IS NULL THEN 1 ELSE 0 END) AS category_id_null,
    SUM(CASE WHEN category           IS NULL THEN 1 ELSE 0 END) AS category_null,
    SUM(CASE WHEN subcategory        IS NULL THEN 1 ELSE 0 END) AS subcategory_null,
    SUM(CASE WHEN product_name       IS NULL THEN 1 ELSE 0 END) AS product_name_null,
    SUM(CASE WHEN product_line       IS NULL THEN 1 ELSE 0 END) AS product_line_null,
    SUM(CASE WHEN maintenance        IS NULL THEN 1 ELSE 0 END) AS maintenance_null,
    SUM(CASE WHEN product_cost               IS NULL THEN 1 ELSE 0 END) AS cost_null,
    SUM(CASE WHEN product_start_date IS NULL THEN 1 ELSE 0 END) AS product_start_date_null
FROM Gold.dim_products;


-- Empty String Check
SELECT *
FROM Gold.dim_products
WHERE
    TRIM(product_name) = ''
    OR TRIM(category) = ''
    OR TRIM(subcategory) = ''
    OR TRIM(product_line) = '';

-- Business Rule Validation
SELECT *
FROM Gold.dim_products
WHERE
    product_cost < 0;

-- Invalid Date Validation
SELECT *
FROM Gold.dim_products
WHERE
    product_start_date > product_end_date;

-- Future Date Validation
SELECT *
FROM Gold.dim_products
WHERE
    product_start_date > GETDATE()
    OR product_end_date > GETDATE();

-- Category Standardization Check
SELECT DISTINCT category
FROM Gold.dim_products
ORDER BY category;

-- Subcategory Standardization Check
SELECT DISTINCT subcategory
FROM Gold.dim_products
ORDER BY subcategory;

-- Product Line Validation
SELECT DISTINCT product_line
FROM Gold.dim_products
ORDER BY product_line;

-- Maintenance Value Validation
SELECT DISTINCT maintenance
FROM Gold.dim_products
ORDER BY maintenance;

SELECT *
FROM Gold.dim_products
WHERE maintenance NOT IN ('Yes', 'No');

-- Fact Table Orphan Check
SELECT *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_products p
    ON f.product_sk = p.product_sk
WHERE p.product_sk IS NULL;

-- Record Count Check
SELECT COUNT(*) AS total_product_records
FROM Gold.dim_products;

-- Unique Product Count
SELECT COUNT(DISTINCT product_id) AS unique_products
FROM Gold.dim_products;

-- SCD Type-2 Validation
SELECT
    product_id,
    product_start_date,
    product_end_date
FROM Gold.dim_products
WHERE product_start_date > product_end_date;


-- Granularity Check
SELECT
    product_id,
    COUNT(*) AS cnt
FROM Gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;