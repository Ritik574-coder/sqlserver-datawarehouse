/*=====================================================================================
View Name: Gold.fact_sales

Description:
This fact view contains transactional sales data at the order-product level.
It stores core business measures such as sales amount, quantity sold,
and unit price along with associated order, shipping, and due dates.
=====================================================================================*/

CREATE VIEW Gold.fact_sales AS 
SELECT 
    sls_ord_num      AS order_number,
    sls_prd_key      AS product_key,
    sls_cust_id      AS customer_id,
    sls_order_dt     AS order_date,
    sls_ship_dt      AS shipping_date,
    sls_due_dt       AS due_date,
    sls_sales        AS sales_amount,
    sls_quantity     AS quantity_sold,
    sls_price        AS unit_price
FROM Silver.crm_sales_details;