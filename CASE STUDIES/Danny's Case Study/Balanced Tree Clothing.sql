Use balanced_tree;

Select * from product_hierarchy;
Select * from product_prices;
Select * from product_details;
Select * from sales;


-- High Level Sales Analysis 
-- 1.What was the total quantity sold for all products?
SELECT SUM(qty) AS total_quantity_sold
FROM balanced_tree.sales;

-- 2.What is the total generated revenue for all products before discounts?
SELECT SUM(qty * price) AS total_revenue_before_discount
FROM balanced_tree.sales;

-- 3.What was the total discount amount for all products? 
SELECT SUM(qty * discount) AS total_discount_amount
FROM balanced_tree.sales;


-- Transaction Analysis
-- 1.How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;

-- 2.What is the average unique products purchased in each transaction?
SELECT AVG(unique_products) AS avg_unique_products_per_transaction
FROM (
  SELECT txn_id, COUNT(DISTINCT prod_id) AS unique_products
  FROM balanced_tree.sales
  GROUP BY txn_id
) t;

-- 3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-- ERROR 
SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY txn_revenue) AS p25,
       PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY txn_revenue) AS p50,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY txn_revenue) AS p75
FROM (
  SELECT txn_id, SUM(qty * price) AS txn_revenue
  FROM balanced_tree.sales
  GROUP BY txn_id
) t;


-- 4.What is the average discount value per transaction?
SELECT AVG(total_discount) AS avg_discount_per_transaction
FROM (
  SELECT txn_id, SUM(qty * discount) AS total_discount
  FROM balanced_tree.sales
  GROUP BY txn_id
) t;


-- 5.What is the percentage split of all transactions for members vs non-members?
SELECT member, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage_split
FROM balanced_tree.sales
GROUP BY member;



-- 6.What is the average revenue for member transactions and non-member transactions?
SELECT member, AVG(total_revenue) AS avg_revenue
FROM (
  SELECT txn_id, member, SUM(qty * price) AS total_revenue
  FROM balanced_tree.sales
  GROUP BY txn_id, member
) t
GROUP BY member;


-- Product Analysis
-- 1.What are the top 3 products by total revenue before discount?
SELECT prod_id, SUM(qty * price) AS total_revenue
FROM balanced_tree.sales
GROUP BY prod_id
ORDER BY total_revenue DESC
LIMIT 3;


-- 2.What is the total quantity, revenue and discount for each segment?
SELECT pd.segment_name, 
       SUM(s.qty) AS total_quantity, 
       SUM(s.qty * s.price) AS total_revenue, 
       SUM(s.qty * s.discount) AS total_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.segment_name;


-- 3.What is the top selling product for each segment?
WITH segment_sales AS (
  SELECT pd.segment_name, s.prod_id, SUM(s.qty) AS total_quantity
  FROM balanced_tree.sales s
  JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
  GROUP BY pd.segment_name, s.prod_id
)
SELECT segment_name, prod_id, total_quantity
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY segment_name ORDER BY total_quantity DESC) AS rnk
  FROM segment_sales
) t
WHERE rnk = 1;



-- 4.What is the total quantity, revenue and discount for each category?
SELECT pd.category_name, 
       SUM(s.qty) AS total_quantity, 
       SUM(s.qty * s.price) AS total_revenue, 
       SUM(s.qty * s.discount) AS total_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.category_name;


-- 5.What is the top selling product for each category?
WITH category_sales AS (
  SELECT pd.category_name, s.prod_id, SUM(s.qty) AS total_quantity
  FROM balanced_tree.sales s
  JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
  GROUP BY pd.category_name, s.prod_id
)
SELECT category_name, prod_id, total_quantity
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY total_quantity DESC) AS rnk
  FROM category_sales
) t
WHERE rnk = 1;



-- 6.What is the percentage split of revenue by product for each segment?
SELECT pd.segment_name, s.prod_id, 
       SUM(s.qty * s.price) * 100.0 / SUM(SUM(s.qty * s.price)) OVER (PARTITION BY pd.segment_name) AS revenue_percentage
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.segment_name, s.prod_id;


-- 7.What is the percentage split of revenue by segment for each category?
SELECT pd.category_name, pd.segment_name, 
       SUM(s.qty * s.price) * 100.0 / SUM(SUM(s.qty * s.price)) OVER (PARTITION BY pd.category_name) AS revenue_percentage
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.segment_name;



-- 8.What is the percentage split of total revenue by category?
SELECT pd.category_name, 
       SUM(s.qty * s.price) * 100.0 / SUM(SUM(s.qty * s.price)) OVER () AS revenue_percentage
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.category_name;


-- 9.What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT prod_id, 
       COUNT(DISTINCT txn_id) * 100.0 / (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales) AS transaction_penetration
FROM balanced_tree.sales
GROUP BY prod_id;


-- 10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
-- Error
WITH product_combinations AS (
  SELECT txn_id, ARRAY_AGG(DISTINCT prod_id) AS products
  FROM balanced_tree.sales
  GROUP BY txn_id
),
combo_count AS (
  SELECT unnest(products) AS product_combo, COUNT(*) AS combo_count
  FROM product_combinations
  WHERE array_length(products, 1) >= 3
  GROUP BY product_combo
)
SELECT product_combo, MAX(combo_count) AS most_common_combo
FROM combo_count;


-- Reporting Challenge
/* A. Write a single SQL script that combines all of the previous questions into a scheduled report that the 
Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end 
of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you 
can easily run the samne analysis for February without many changes (if at all). */

-- Set the reporting period
WITH reporting_period AS (
  SELECT 
    DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') AS start_date,
    DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 second' AS end_date
),

-- High Level Sales Analysis
high_level_sales AS (
  SELECT 
    SUM(qty) AS total_quantity_sold,
    SUM(qty * price) AS total_revenue_before_discount,
    SUM(qty * discount) AS total_discount_amount
  FROM balanced_tree.sales
  WHERE start_txn_time BETWEEN (SELECT start_date FROM reporting_period)
                           AND (SELECT end_date FROM reporting_period)
),

-- Transaction Analysis
transaction_analysis AS (
  SELECT 
    COUNT(DISTINCT txn_id) AS unique_transactions,
    AVG(products_per_txn) AS avg_unique_products_per_transaction,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue_per_txn) AS revenue_25th_percentile,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue_per_txn) AS revenue_50th_percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue_per_txn) AS revenue_75th_percentile,
    AVG(discount_per_txn) AS avg_discount_per_transaction,
    SUM(CASE WHEN member THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS member_transaction_percentage,
    SUM(CASE WHEN NOT member THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS non_member_transaction_percentage,
    AVG(CASE WHEN member THEN txn_revenue ELSE NULL END) AS avg_revenue_member_transactions,
    AVG(CASE WHEN NOT member THEN txn_revenue ELSE NULL END) AS avg_revenue_non_member_transactions
  FROM (
    SELECT 
      txn_id,
      COUNT(DISTINCT prod_id) AS products_per_txn,
      SUM(qty * price) AS revenue_per_txn,
      SUM(qty * discount) AS discount_per_txn,
      SUM(qty * price) - SUM(qty * discount) AS txn_revenue,
      MAX(member) AS member
    FROM balanced_tree.sales
    WHERE start_txn_time BETWEEN (SELECT start_date FROM reporting_period)
                             AND (SELECT end_date FROM reporting_period)
    GROUP BY txn_id
  ) subquery
),

-- Product Analysis
product_analysis AS (
  SELECT 
    product_id,
    SUM(qty) AS total_quantity,
    SUM(qty * price) AS total_revenue,
    SUM(qty * discount) AS total_discount
  FROM balanced_tree.sales
  WHERE start_txn_time BETWEEN (SELECT start_date FROM reporting_period)
                           AND (SELECT end_date FROM reporting_period)
  GROUP BY product_id
),
top_products AS (
  SELECT 
    product_id,
    total_revenue
  FROM product_analysis
  ORDER BY total_revenue DESC
  LIMIT 3
),
segment_analysis AS (
  SELECT 
    pd.segment_id,
    pd.segment_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty * s.price) AS total_revenue,
    SUM(s.qty * s.discount) AS total_discount
  FROM balanced_tree.sales s
  JOIN balanced_tree.product_details pd
    ON s.prod_id = pd.product_id
  WHERE s.start_txn_time BETWEEN (SELECT start_date FROM reporting_period)
                             AND (SELECT end_date FROM reporting_period)
  GROUP BY pd.segment_id, pd.segment_name
),
category_analysis AS (
  SELECT 
    pd.category_id,
    pd.category_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.qty * s.price) AS total_revenue,
    SUM(s.qty * s.discount) AS total_discount
  FROM balanced_tree.sales s
  JOIN balanced_tree.product_details pd
    ON s.prod_id = pd.product_id
  WHERE s.start_txn_time BETWEEN (SELECT start_date FROM reporting_period)
                             AND (SELECT end_date FROM reporting_period)
  GROUP BY pd.category_id, pd.category_name
)

-- Final Combined Report
SELECT 
  -- High Level Sales Analysis
  hls.total_quantity_sold,
  hls.total_revenue_before_discount,
  hls.total_discount_amount,
  
  -- Transaction Analysis
  ta.unique_transactions,
  ta.avg_unique_products_per_transaction,
  ta.revenue_25th_percentile,
  ta.revenue_50th_percentile,
  ta.revenue_75th_percentile,
  ta.avg_discount_per_transaction,
  ta.member_transaction_percentage,
  ta.non_member_transaction_percentage,
  ta.avg_revenue_member_transactions,
  ta.avg_revenue_non_member_transactions,
  
  -- Product Analysis (Top 3 Products by Revenue)
  tp.product_id AS top_product_id,
  tp.total_revenue AS top_product_revenue,
  
  -- Segment Analysis
  sa.segment_id,
  sa.segment_name,
  sa.total_quantity AS segment_quantity,
  sa.total_revenue AS segment_revenue,
  sa.total_discount AS segment_discount,
  
  -- Category Analysis
  ca.category_id,
  ca.category_name,
  ca.total_quantity AS category_quantity,
  ca.total_revenue AS category_revenue,
  ca.total_discount AS category_discount
FROM high_level_sales hls
CROSS JOIN transaction_analysis ta
LEFT JOIN top_products tp ON TRUE
LEFT JOIN segment_analysis sa ON TRUE
LEFT JOIN category_analysis ca ON TRUE;




-----------------------------------------------------------------------------------------------------
-- B. Bonus Challenge
-- Use a single SQL query to Transform the product_hierarchy and product_prices datasets to the product_details 
-- table.

-- Hint: you may want to consider using a recursive CTE to solve this problem!
-- ERROR 

WITH RECURSIVE hierarchy AS (
  SELECT id, parent_id, level_text, level_name
  FROM balanced_tree.product_hierarchy
  WHERE parent_id IS NULL
  UNION ALL
  SELECT h.id, ph.parent_id, ph.level_text, ph.level_name
  FROM hierarchy h
  JOIN balanced_tree.product_hierarchy ph ON h.id = ph.parent_id
)
SELECT h.id AS category_id, p.product_id, p.price, h.level_text AS category_name
FROM hierarchy h
JOIN balanced_tree.product_prices p ON h.id = p.id;



