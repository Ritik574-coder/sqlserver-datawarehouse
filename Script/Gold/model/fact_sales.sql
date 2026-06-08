/*=====================================================================================
View Name: Gold.fact_sales

Description:
This fact view contains transactional sales data at the order-product level.
It stores core business measures such as sales amount, quantity sold,
and unit price along with associated order, shipping, and due dates.
=====================================================================================*/

CREATE VIEW Gold.fact_sales AS 
SELECT 
    ROW_NUMBER() OVER(ORDER BY sls_ord_num) sales_sk ,
    p.product_sk      AS product_sk,
    c.customer_sk      AS customer_sk,
    s.sls_ord_num      AS order_number,
    s.sls_order_dt     AS order_date,
    s.sls_ship_dt      AS shipping_date,
    s.sls_due_dt       AS due_date,
    s.sls_sales        AS sales_amount,
    s.sls_quantity     AS quantity_sold,
    s.sls_price        AS unit_price
FROM Silver.crm_sales_details as s
LEFT JOIN Gold.dim_customers as c 
ON c.customer_id = s.sls_cust_id 
LEFT JOIN Gold.dim_products as p 
ON s.sls_prd_key = p.product_key 
GO;