CREATE SCHEMA fresh_segments;

DROP TABLE IF EXISTS fresh_segments.json_data;
CREATE TABLE fresh_segments.json_data (raw_data JSON);

CREATE TABLE fresh_segments.interest_map (
  id INTEGER,
  interest_name TEXT,
  interest_summary TEXT,
  created_at TIMESTAMP,
  last_modified TIMESTAMP
);

USE fresh_segments;

INSERT INTO fresh_segments.interest_map (id, interest_name, interest_summary, created_at, last_modified) 
VALUES
(1, 'Fitness Enthusiasts', 'Consumers using fitness tracking apps and websites.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(2, 'Gamers', 'Consumers researching game reviews and cheat codes.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(3, 'Car Enthusiasts', 'Readers of automotive news and car reviews.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(4, 'Luxury Retail Researchers', 'Consumers researching luxury product reviews and gift ideas.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(5, 'Brides & Wedding Planners', 'People researching wedding ideas and vendors.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(6, 'Vacation Planners', 'Consumers reading reviews of vacation destinations and accommodations.', '2016-05-26 14:57:59', '2018-05-23 11:30:13'),
(7, 'Motorcycle Enthusiasts', 'Readers of motorcycle news and reviews.', '2016-05-26 14:57:59', '2018-05-23 11:30:13'),
(8, 'Business News Readers', 'Readers of online business news content.', '2016-05-26 14:57:59', '2018-05-23 11:30:12'),
(12, 'Thrift Store Shoppers', 'Consumers shopping online for clothing at thrift stores and researching locations.', '2016-05-26 14:57:59', '2018-03-16 13:14:00'),
(13, 'Advertising Professionals', 'People who read advertising industry news.', '2016-05-26 14:57:59', '2018-05-23 11:30:12');

CREATE TABLE Interest_Metrics 
(
	_month int,
    _year int,
    month_year varchar(50),
    interest_id varchar(50),
    composition decimal(10,2),
    index_value decimal(10,2),
    ranking int,
    percentile_ranking decimal(20,2));

INSERT INTO Interest_Metrics (_month, _year, month_year, interest_id, composition, index_value, ranking, percentile_ranking) 
VALUES
(7, 2018, '07-2018', '32486', 11.89, 6.19, 1, 99.86),
(7, 2018, '07-2018', '6106', 9.93, 5.31, 2, 99.73),
(7, 2018, '07-2018', '18923', 10.85, 5.29, 3, 99.59),
(7, 2018, '07-2018', '6344', 10.32, 5.10, 4, 99.45),
(7, 2018, '07-2018', '100', 10.77, 5.04, 5, 99.31),
(7, 2018, '07-2018', '69', 10.82, 5.03, 6, 99.18),
(7, 2018, '07-2018', '79', 11.21, 4.97, 7, 99.04),
(7, 2018, '07-2018', '6111', 10.71, 4.83, 8, 98.90),
(7, 2018, '07-2018', '6214', 9.71, 4.83, 8, 98.90),
(7, 2018, '07-2018', '19422', 10.11, 4.81, 10, 98.63);

-- Displaying the records from the created tables
SELECT * FROM fresh_segments.interest_map;

SELECT * FROM fresh_segments.Interest_Metrics;


-- Data is huge need to be updated 

-- Data Exploration and Cleansing

-- 1.Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE fresh_segments.Interest_Metrics 
MODIFY month_year DATE;

UPDATE fresh_segments.Interest_Metrics 
SET month_year = STR_TO_DATE(CONCAT(_year, '-', _month, '-01'), '%Y-%m-%d');



-- 2.What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT 
    month_year, 
    COUNT(*) AS record_count
FROM fresh_segments.Interest_Metrics
GROUP BY month_year
ORDER BY month_year IS NULL, month_year;



-- 3.What do you think we should do with these null values in the fresh_segments.interest_metrics




-- 4.How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
-- Interest IDs in Interest_Metrics but not in Interest_Map
SELECT COUNT(DISTINCT interest_id) AS metrics_not_in_map
FROM fresh_segments.Interest_Metrics
WHERE interest_id NOT IN (SELECT id FROM fresh_segments.interest_map);

-- Interest IDs in Interest_Map but not in Interest_Metrics
SELECT COUNT(DISTINCT id) AS map_not_in_metrics
FROM fresh_segments.interest_map
WHERE id NOT IN (SELECT interest_id FROM fresh_segments.Interest_Metrics);




-- 5.Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT 
    id, 
    COUNT(*) AS total_records
FROM fresh_segments.interest_map
GROUP BY id;



-- 6.What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT 
    m.*, 
    i.interest_name, 
    i.interest_summary, 
    i.created_at, 
    i.last_modified
FROM fresh_segments.Interest_Metrics m
LEFT JOIN fresh_segments.interest_map i
ON m.interest_id = i.id
WHERE m.interest_id = 21246;




-- 7.Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
SELECT 
    m.*, 
    i.created_at
FROM fresh_segments.Interest_Metrics m
JOIN fresh_segments.interest_map i
ON m.interest_id = i.id
WHERE m.month_year < i.created_at;






-- Interest Analysis

-- 1.Which interests have been present in all month_year dates in our dataset?
SELECT 
    interest_id, 
    COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.Interest_Metrics
GROUP BY interest_id
HAVING total_months = (SELECT COUNT(DISTINCT month_year) FROM fresh_segments.Interest_Metrics);



-- 2.Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH interest_counts AS (
    SELECT 
        interest_id, 
        COUNT(DISTINCT month_year) AS total_months
    FROM fresh_segments.Interest_Metrics
    GROUP BY interest_id
),
cumulative_percentage AS (
    SELECT 
        total_months, 
        COUNT(*) AS count_interests, 
        SUM(COUNT(*)) OVER (ORDER BY total_months) * 1.0 / SUM(COUNT(*)) OVER () AS cumulative_percentage
    FROM interest_counts
    GROUP BY total_months
)
SELECT total_months
FROM cumulative_percentage
WHERE cumulative_percentage >= 0.9
LIMIT 1;



-- 3.If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
SELECT COUNT(*)
FROM fresh_segments.Interest_Metrics
WHERE interest_id IN (
    SELECT interest_id
    FROM (
        SELECT 
            interest_id, 
            COUNT(DISTINCT month_year) AS total_months
        FROM fresh_segments.Interest_Metrics
        GROUP BY interest_id
        HAVING total_months < 14
    ) t
);


-- 4.Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.




-- 5.After removing these interests - how many unique interests are there for each month?alter
SELECT 
    month_year, 
    COUNT(DISTINCT interest_id) AS unique_interests
FROM fresh_segments.Interest_Metrics
WHERE interest_id IN (
    SELECT interest_id
    FROM (
        SELECT 
            interest_id, 
            COUNT(DISTINCT month_year) AS total_months
        FROM fresh_segments.Interest_Metrics
        GROUP BY interest_id
        HAVING total_months >= 14
    ) t
)
GROUP BY month_year;




-- Segment Analysis

-- 1.Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
WITH max_compositions AS (
    SELECT 
        interest_id, 
        month_year, 
        MAX(composition) AS max_composition
    FROM fresh_segments.Interest_Metrics
    GROUP BY interest_id, month_year
)
SELECT *
FROM max_compositions
ORDER BY max_composition DESC
LIMIT 10;

-- Bottom 10
SELECT *
FROM max_compositions
ORDER BY max_composition ASC
LIMIT 10;




-- 2.Which 5 interests had the lowest average ranking value?
SELECT 
    interest_id, 
    AVG(ranking) AS avg_ranking
FROM fresh_segments.Interest_Metrics
GROUP BY interest_id
ORDER BY avg_ranking ASC
LIMIT 5;


-- 3.Which 5 interests had the largest standard deviation in their percentile_ranking value?
SELECT 
    interest_id, 
    STDDEV(percentile_ranking) AS stddev_percentile
FROM fresh_segments.Interest_Metrics
GROUP BY interest_id
ORDER BY stddev_percentile DESC
LIMIT 5;


-- 4.For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
SELECT 
    interest_id,
    MIN(percentile_ranking) AS min_percentile_ranking,
    MAX(percentile_ranking) AS max_percentile_ranking,
    MIN(month_year) AS min_month_year,
    MAX(month_year) AS max_month_year
FROM fresh_segments.interest_metrics
WHERE interest_id IN (SELECT interest_id 
                      FROM fresh_segments.interest_metrics
                      GROUP BY interest_id
                      ORDER BY STDDEV(percentile_ranking) DESC
                      LIMIT 5)
GROUP BY interest_id;





-- 5.How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

-- Index Analysis

/* The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places. */

-- 1.What is the top 10 interests by the average composition for each month?
WITH avg_composition AS (
    SELECT 
        month_year, 
        interest_id, 
        ROUND(AVG(composition / index_value), 2) AS avg_composition
    FROM fresh_segments.Interest_Metrics
    GROUP BY month_year, interest_id
)
SELECT *
FROM avg_composition
ORDER BY avg_composition DESC
LIMIT 10;


-- 2.For all of these top 10 interests - which interest appears the most often?
WITH Top10Interests AS (
    SELECT 
        interest_id,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition DESC) AS rank
    FROM fresh_segments.interest_metrics
)
SELECT 
    interest_id, 
    COUNT(*) AS appearance_count
FROM Top10Interests
WHERE rank <= 10
GROUP BY interest_id
ORDER BY appearance_count DESC
LIMIT 1;



-- 3.What is the average of the average composition for the top 10 interests for each month?
WITH Top10Interests AS (
    SELECT 
        month_year,
        interest_id,
        composition / index_value AS average_composition,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition DESC) AS rank
    FROM fresh_segments.interest_metrics
)
SELECT 
    month_year,
    ROUND(AVG(average_composition), 2) AS avg_of_avg_composition
FROM Top10Interests
WHERE rank <= 10
GROUP BY month_year
ORDER BY month_year;



-- 4.What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
WITH AvgComposition AS (
    SELECT 
        month_year,
        MAX(composition / index_value) AS max_avg_composition
    FROM fresh_segments.interest_metrics
    WHERE month_year BETWEEN '2018-09-01' AND '2019-08-31'
    GROUP BY month_year
),
RollingAverage AS (
    SELECT 
        month_year,
        max_avg_composition,
        ROUND(AVG(max_avg_composition) 
              OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg
    FROM AvgComposition
)
SELECT 
    month_year,
    max_avg_composition,
    rolling_avg
FROM RollingAverage
ORDER BY month_year;




-- 5.Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?alter

