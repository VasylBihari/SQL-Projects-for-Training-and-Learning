/*The product team wants to analyze the most frequently reordered product categories. 
Can you provide a list of the product category codes (using first 3 letters of product code) and their reorder counts for Q4 2024?
Tables
fct_orders(order_id, customer_id, product_id, reorder_flag, order_date)
dim_products(product_id, product_code, category)
dim_customers(customer_id, customer_name)*/

SELECT
  DISTINCT(LEFT(d.product_code, 3)),
  COUNT (LEFT(d.product_code, 3))
FROM dim_products d
INNER JOIN fct_orders f ON d.product_id=f.product_id
WHERE f.order_date BETWEEN '2024-10-01' AND '2024-12-31'
AND reorder_flag = '1'
GROUP BY LEFT(d.product_code, 3)
ORDER BY count DESC

/*To better understand customer preferences, the team needs to know the details of customers who reorder specific products. 
Can you retrieve the customer information along with their reordered product code(s) for Q4 2024?
Tables
fct_orders(order_id, customer_id, product_id, reorder_flag, order_date)
dim_products(product_id, product_code, category)
dim_customers(customer_id, customer_name)*/

 SELECT
  d.customer_id,
  d.customer_name,
  p.product_code
FROM dim_customers d
INNER JOIN fct_orders f ON d.customer_id=f.customer_id
INNER JOIN dim_products p ON p.product_id=f.product_id
WHERE order_date BETWEEN '2024-10-01' AND '2024-12-31'
AND reorder_flag = '1'

/*When calculating the average reorder frequency, it's important to handle cases where reorder counts may be missing or zero. 
Can you compute the average reorder frequency across the product categories, ensuring that any missing or null values are appropriately managed for Q4 2024?
Tables
fct_orders(order_id, customer_id, product_id, reorder_flag, order_date)
dim_products(product_id, product_code, category)
dim_customers(customer_id, customer_name)*/

WITH filtered_orders AS (
    SELECT
        fo.order_id,
        fo.product_id,
        COALESCE(fo.reorder_flag, 0) AS reorder_flag
    FROM fct_orders fo
    WHERE fo.order_date >= '2024-10-01'
      AND fo.order_date <= '2024-12-31'
),
joined_data AS (
    SELECT
        fo.order_id,
        dp.category,
        fo.reorder_flag
    FROM filtered_orders fo
    LEFT JOIN dim_products dp
        ON fo.product_id = dp.product_id
)
SELECT
    category,
    COUNT(*) AS total_orders,
    SUM(reorder_flag) AS total_reorders,
    ROUND(
        SUM(reorder_flag)::numeric / NULLIF(COUNT(*), 0),
        4
    ) AS avg_reorder_frequency
FROM joined_data
GROUP BY category
ORDER BY avg_reorder_frequency DESC
