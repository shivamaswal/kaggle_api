SELECT *
FROM df_orders;

-- Top 10 highest revenue generating products
SELECT TOP 10 product_id , SUM(sale_price) as total_revenue
FROM df_orders
GROUP BY product_id
ORDER BY total_revenue DESC;

-- Top 5 highest selling products in each region 
SELECT region,product_id,rnk
FROM (
SELECT region, product_id , SUM(sale_price) as total_sales , ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) as rnk
FROM df_orders
GROUP BY region, product_id) as subquerry
WHERE rnk <= 5;

-- Find month over month growth comparision for 2022 and 2023 sales eg jan 2022 vs jan 2023
WITH cte AS(
SELECT YEAR(order_date) as order_year , MONTH(order_date) as order_month ,
SUM(sale_price) as revenue
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT order_month , 
SUM(CASE WHEN order_year = 2022 THEN revenue else 0 END) as revenue_2022,
SUM(CASE WHEN order_year = 2023 THEN revenue else 0 END) as revenue_2023 
FROM cte
GROUP BY order_month

-- for each category which month had the highest sales
SELECT category , date
FROM(
SELECT category , FORMAT(order_date,'yyyy-MM') as date, SUM(sale_price) as total_sales,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) as rnk
FROM df_orders
GROUP BY category , FORMAT(order_date,'yyyy-MM')) as subquerry
WHERE rnk = 1;

--which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS(
SELECT sub_category, YEAR(order_date) as yrs , SUM(sale_price) as total_sales
FROM df_orders
GROUP BY sub_category,YEAR(order_date) ),
cte_2 AS(
SELECT sub_category,sales_2022,sales_2023 ,((sales_2023 - sales_2022)/sales_2022)*100 as growth_percent
FROM
(SELECT sub_category,
SUM(CASE WHEN yrs = 2022 THEN total_sales END) as sales_2022,
SUM(CASE WHEN yrs = 2023 THEN total_sales END) as sales_2023
FROM cte
GROUP BY sub_category) as subquerry
)

SELECT TOP 1 sub_category , sales_2022 , sales_2023, growth_percent
FROM cte_2
ORDER BY growth_percent DESC


