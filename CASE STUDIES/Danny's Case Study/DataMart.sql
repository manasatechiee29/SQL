-- 1.Data Cleaning Steps 
/* In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

Convert the week_date to a DATE format

Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

Add a month_number with the calendar month for each week_date value as the 3rd column

Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
Add a new demographic column using the following mapping for the first letter in the segment values:
Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record */

-- 1.Convert the week_date to a DATE format
-- desc weekly_sales;

-- 2.Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

-- 3.Add a month_number with the calendar month for each week_date value as the 3rd column

-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

-- Add a new demographic column using the following mapping for the first letter in the segment values:

-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

CREATE TABLE data_mart.clean_weekly_sales AS
SELECT 
    -- Convert the week_date to a DATE format
    STR_TO_DATE(week_date, '%Y-%m-%d') AS week_date,
    
    -- Add a week_number
    WEEK(STR_TO_DATE(week_date, '%Y-%m-%d')) AS week_number,
    
    -- Add a month_number
    MONTH(STR_TO_DATE(week_date, '%Y-%m-%d')) AS month_number,
    
    -- Add a calendar_year column
    CASE 
        WHEN STR_TO_DATE(week_date, '%Y-%m-%d') BETWEEN '2018-01-01' AND '2018-12-31' THEN 2018
        WHEN STR_TO_DATE(week_date, '%Y-%m-%d') BETWEEN '2019-01-01' AND '2019-12-31' THEN 2019
        WHEN STR_TO_DATE(week_date, '%Y-%m-%d') BETWEEN '2020-01-01' AND '2020-12-31' THEN 2020
        ELSE NULL
    END AS calendar_year,
    
    -- Add a new column for age_band
    CASE 
        WHEN segment = '1' THEN 'Young Adults'
        WHEN segment = '2' THEN 'Middle Aged'
        WHEN segment IN ('3', '4') THEN 'Retirees'
        ELSE 'unknown'
    END AS age_band,
    
    -- Add a new demographic column
    CASE 
        WHEN segment LIKE 'C%' THEN 'Couples'
        WHEN segment LIKE 'F%' THEN 'Families'
        ELSE 'unknown'
    END AS demographic,
    
    -- Ensure null values are replaced with 'unknown'
    IFNULL(segment, 'unknown') AS segment,
    IFNULL(age_band, 'unknown') AS age_band,
    IFNULL(demographic, 'unknown') AS demographic,
    
    -- Generate a new avg_transaction column
    ROUND(sales / transactions, 2) AS avg_transaction
    
FROM data_mart.weekly_sales;


-- 2. Data Exploration 
-- 1.What day of the week is used for each week_date value?

SELECT 
    week_date,
    DAYNAME(STR_TO_DATE(week_date, '%Y-%m-%d')) AS day_of_week
FROM data_mart.clean_weekly_sales;


-- 2.What range of week numbers are missing from the dataset?
SELECT 
    MIN(week_number) AS min_week_number,
    MAX(week_number) AS max_week_number
FROM data_mart.clean_weekly_sales;


-- 3.How many total transactions were there for each year in the dataset?
SELECT 
    calendar_year,
    SUM(transactions) AS total_transactions
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year;



-- 4.What is the total sales for each region for each month?
SELECT 
    region,
    month_number,
    SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;


-- 5.What is the total count of transactions for each platform
SELECT 
    platform,
    SUM(transactions) AS total_transactions
FROM data_mart.clean_weekly_sales
GROUP BY platform;


-- 6.What is the percentage of sales for Retail vs Shopify for each month?
SELECT 
    month_number,
    platform,
    ROUND((SUM(sales) / (SELECT SUM(sales) FROM data_mart.clean_weekly_sales WHERE month_number = cs.month_number)) * 100, 2) AS sales_percentage
FROM data_mart.clean_weekly_sales cs
WHERE platform IN ('Retail', 'Shopify')
GROUP BY month_number, platform;



-- 7.What is the percentage of sales by demographic for each year in the dataset?
SELECT 
    calendar_year,
    demographic,
    ROUND((SUM(sales) / (SELECT SUM(sales) FROM data_mart.clean_weekly_sales WHERE calendar_year = cs.calendar_year)) * 100, 2) AS sales_percentage
FROM data_mart.clean_weekly_sales cs
GROUP BY calendar_year, demographic;




-- 8.Which age_band and demographic values contribute the most to Retail sales?
SELECT 
    age_band,
    demographic,
    SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC
LIMIT 1;

-- 9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
    calendar_year,
    platform,
    ROUND(SUM(sales) / SUM(transactions), 2) AS avg_transaction_size
FROM data_mart.clean_weekly_sales
WHERE platform IN ('Retail', 'Shopify')
GROUP BY calendar_year, platform;




-- 3. Before & After Analysis 
/* This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1.What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?



2.What about the entire 12 weeks before and after?
3.How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019? */

-- 1. 
WITH sales_before_after AS (
    SELECT 
        week_date,
        SUM(sales) AS total_sales
    FROM data_mart.clean_weekly_sales
    WHERE week_date BETWEEN '2020-05-18' AND '2020-07-13'
    GROUP BY week_date
)
SELECT 
    'Before' AS period,
    SUM(CASE WHEN week_date < '2020-06-15' THEN total_sales ELSE 0 END) AS total_sales_before,
    SUM(CASE WHEN week_date >= '2020-06-15' THEN total_sales ELSE 0 END) AS total_sales_after,
    ROUND((SUM(CASE WHEN week_date >= '2020-06-15' THEN total_sales ELSE 0 END) - 
          SUM(CASE WHEN week_date < '2020-06-15' THEN total_sales ELSE 0 END)) 
          / SUM(CASE WHEN week_date < '2020-06-15' THEN total_sales ELSE 0 END) * 100, 2) AS sales_growth_percentage
FROM sales_before_after;


-- 2. 
SELECT 
    calendar_year,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT week_date), 2) AS avg_sales_per_week
FROM data_mart.clean_weekly_sales
WHERE week_date BETWEEN '2018-05-18' AND '2018-07-13' 
   OR week_date BETWEEN '2019-05-18' AND '2019-07-13'
GROUP BY calendar_year;


-- 4. 
SELECT 
    region, 
    platform, 
    age_band, 
    demographic, 
    customer_type,
    ROUND(SUM(sales) / COUNT(DISTINCT week_date), 2) AS avg_sales_per_week
FROM data_mart.clean_weekly_sales
WHERE week_date BETWEEN '2020-05-18' AND '2020-07-13'
GROUP BY region, platform, age_band, demographic, customer_type
ORDER BY avg_sales_per_week ASC
LIMIT 1;


-- 4. Bonus Question
/* Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

1.region
2.platform
3.age_band
4.demographic
5.customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis? */
