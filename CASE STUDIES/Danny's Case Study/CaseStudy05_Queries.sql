-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record */
use data_mart;

UPDATE weekly_sales
SET
	region = NULLIF(region, 'null'),
    platform = NULLIF(platform, 'null'),
    segment = NULLIF(segment, 'null'),
    customer_type = NULLIF(customer_type, 'null');


-- 1.Convert the week_date to a DATE format
-- 2.Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- 3.Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
-- Add a new demographic column using the following mapping for the first letter in the segment values:
-- Ensure all null ring values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
Select * from weekly_sales;

CREATE TABLE data_mart.clean_weekly_sales AS
SELECT
	-- Convert week_date to DATE format
    str_to_date(week_date,'%d/%m/%Y') AS week_date,
    
    -- Add week_number: Calculate the week of the month
    CEIL(DAY(STR_TO_DATE(week_date, '%d/%m/%Y'))/7) AS week_number,
    
    -- Add month_number: Extract the month
	MONTH(str_to_date(week_date, '%d/%m/%Y')) AS month_number,
    
    -- Add calendar_year: Extract the year
    YEAR(STR_TO_DATE(week_date, '%d/%m/%Y')) AS calendar_year,
    
    -- Retain original columns
    region,
    platform,
    
    -- Handle NULL values in segment column with "unknown"
    COALESCE(segment, 'unknown') AS segment,
    
    -- Add age_band column
    CASE
		WHEN RIGHT(COALESCE(segment, 'unknown'), 1) = '1' THEN 'Young Adults'
        WHEN RIGHT(COALESCE(segment, 'unknown'), 1) = '2' THEN 'Middle Aged'
        WHEN RIGHT(COALESCE(segment, 'unknown'), 1) IN ('3','4') THEN 'Retirees'
        ELSE 'unknown'
	END AS age_band,
    
    -- Add demographic column
	CASE 
		WHEN LEFT(COALESCE(segment, 'unknown'), 1) = 'C' THEN 'Couples'
        WHEN LEFT(COALESCE(segment, 'unknown'), 1) = 'F' THEN 'Families'
        ELSE 'unknown'
	END AS demographic,
    
    -- Retain customer_type column
    customer_type,
    
    -- Retain transactions and sales columns
    transactions,
    sales,
    
    -- Calculate avg_transaction as sales divided by transactions rounded to 2 decimal places
    ROUND(sales/transactions, 2) AS avg_transaction
from weekly_sales;

Select * from clean_weekly_sales;

-- 2. Data Exploration 
-- 1.What day of the week is used for each week_date value?
SELECT 
    distinct(DAYNAME(week_date)) AS day_name
FROM data_mart.clean_weekly_sales;

-- 2.What range of week numbers are missing from the dataset? - wrong answer need to work on 
SELECT
	DISTINCT WEEK(WEEK_DATE) AS week_number
FROM clean_weekly_sales
ORDER BY week(week_date) ASC;

WITH all_weeks AS(
	SELECT WEEK_NUMBER
    FROM ( 
		SELECT 1 AS WEEK_NUMBER UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
        UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
        UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
        UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
        UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
        UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35
        UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40
        UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45
        UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50
        UNION ALL SELECT 51 UNION ALL SELECT 52 UNION ALL SELECT 53
	) AS weeks
)

SELECT 
	all_weeks.WEEK_NUMBER AS missing_week_numbers
FROM 
	all_weeks
LEFT JOIN (
	SELECT DISTINCT week_number
    FROM data_mart.clean_weekly_sales
) existing_weeks
ON all_weeks.WEEK_NUMBER = existing_weeks.week_number
WHERE existing_weeks.week_number IS NULL;


-- 3.How many total transactions were there for each year in the dataset?

SELECT year(week_date) AS YEAR, sum(transactions) as total_transactions
FROM clean_weekly_sales
GROUP BY YEAR
ORDER BY 1;

-- 4.What is the total sales for each region for each month?
SELECT 
	region,
    month_number,
    monthname(week_date) as Month, 
    sum(sales) as Total_sales 
FROM 
	clean_weekly_sales
GROUP BY 
	region, month
Order by 
	1,2;

-- 5.What is the total count of transactions for each platform
SELECT 
	platform,
    sum(transactions) as Total_count_of_Transactions
FROM 
	clean_weekly_sales
GROUP BY 
	platform
ORDER BY 
	1;

-- 6.What is the percentage of sales for Retail vs Shopify for each month?
WITH sales_cte as(
	Select 
		calendar_year,
        month_number,
        SUM(CASE
				WHEN platform = "Retail" THEN sales
			END) AS retail_sales,
		SUM(CASE
				WHEN platform = "Shopify" THEN sales
			END) AS shopify_sales,
		SUM(Sales) AS total_sales
	FROM clean_weekly_sales
    GROUP BY 1, 
			 2
	ORDER BY 1, 
			 2)
             
SELECT Calendar_year,
		month_number,
        ROUND(retail_sales/total_sales*100, 2) AS retail_percent,
        ROUND(shopify_sales/total_sales * 100, 2) AS shopify_percent
FROM sales_cte;


-- 7.What is the percentage of sales by demographic for each year in the dataset?
With sales_cte AS
	(SELECT calendar_year,
			month_number,
            SUM(CASE
					WHEN demographic = "Couples" THEN Sales
				END) AS Couples_demo,
			SUM(CASE
					WHEN demographic = "Families" THEN Sales
				END) AS Families_demo,
			SUM(CASE
					WHEN demographic = "Unknown" THEN Sales
				END) AS Unknown_demo,
			sum(sales) as Total_sales
	FROM clean_weekly_sales
    GROUP BY 1,
			 2
	ORDER BY 1,
			 2)

SELECT calendar_year,
		month_number,
        ROUND(Couples_demo/total_sales * 100, 2) AS Couples_percent,
        ROUND(Families_demo/total_sales * 100, 2) AS Families_percent,
        ROUND(Unknown_demo/total_sales * 100, 2) AS Unknown_percent
FROM Sales_cte;

-- or 

WITH sales_contribution_cte as
	(SELECT calendar_year,
			demographic,
            sum(Sales) as sales_contribution
	FROM clean_weekly_sales
    GROUP BY 1,
			2
	ORDER BY 1),
		total_sales_cte AS
	(SELECT *,
		sum(sales_contribution) over (PARTITION BY calendar_year) AS total_sales
	FROM sales_contribution_cte)
    
SELECT calendar_year,
	demographic,
    ROUND(100 * sales_contribution / total_sales, 2) AS percent_sales_contribution
FROM total_sales_cte
GROUP BY 1,
		2;

-- 8.Which age_band and demographic values contribute the most to Retail sales?

SELECT age_band,
		demographic,
        ROUND(100 * sum(sales)/
				(SELECT SUM(sales)
				FROM clean_weekly_sales
                WHERE platform = "Retail"),2) AS retail_sales_percentage
FROM clean_weekly_sales
WHERE platform = "Retail"
GROUP BY 1,
		 2
ORDER BY 3 DESC;


-- 9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT Calendar_year,
		platform,
        ROUND(SUM(sales)/SUM(transactions),2) AS correct_avg,
        ROUND(AVG(avg_transaction),2) AS incorrect_avg
FROM clean_weekly_sales
GROUP BY 1,
		2
ORDER BY 1,
		2;
        

-- 3. Before & After Analysis 
/* This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1.What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
2.What about the entire 12 weeks before and after?
3.How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019? */

-- 4. Bonus Question
/* Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

1.region
2.platform
3.age_band
4.demographic
5.customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis? */
