SELECT TOP 10 * FROM Gold.dim_customers ; 
SELECT TOP 10 * FROM Gold.dim_products ; 
SELECT TOP 10 * FROM Gold.fact_sales ; 

SELECT 
c.customer_id,
s.sales_sk,
P.product_key ,
s.unit_price 
FROM Gold.dim_customers as c 
LEFT JOIN Gold.fact_sales as s
ON C.customer_id = s.customer_id
LEFT JOIN Gold.dim_products as p  
ON p.product_key = s.product_key 
; 
