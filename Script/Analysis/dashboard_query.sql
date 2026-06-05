SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS monthly_sales
FROM Gold.fact_sales
GROUP BY 
    YEAR(order_date),
    MONTH(order_date)
ORDER BY year, month;

SELECT
    sales_sk
FROM Gold.fact_sales  
WHERE sales_sk IS NULL ;
