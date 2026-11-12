use clique_bait;

-- Executing the Tables
Select * from event_identifier;  
Select * from campaign_identifier; 
Select * from page_hierarchy;  
Select * from users; 
Select * from Events;


-- Create the "Users" table
CREATE TABLE Users(
	user_id INT NOT NULL, 
    cookie_id VARCHAR(10) NOT NULL, 
    start_date DATETIME NOT NULL
);

-- Insert data into the "Users" Table
INSERT INTO Users (user_id, cookie_id, start_date) VALUES
(397, '3759ff', '2020-03-30 00:00:00'),
(215, '863329', '2020-01-26 00:00:00'),
(191, 'eefca9', '2020-03-15 00:00:00'),
(89,  '764796', '2020-01-07 00:00:00'),
(127, '17ccc5', '2020-01-22 00:00:00'),
(81,  'b0b666', '2020-03-01 00:00:00'),
(260, 'a4f236', '2020-01-08 00:00:00'),
(203, 'd1182f', '2020-04-18 00:00:00'),
(23,  '12dbc8', '2020-01-18 00:00:00'),
(375, 'f61d69', '2020-01-03 00:00:00');

SELECT * FROM Users;
SELECT * FROM Events;

drop table Events;
drop table Users;

-- Create the Events table
CREATE TABLE Events(
	visit_id VARCHAR(10) , 
    cookie_id VARCHAR(10) ,
    page_id INT , 
    event_type INT ,
    sequence_number INT , 
    event_time DATETIME(6) , 
    PRIMARY KEY (visit_id)
);

-- Insert data into the "Events" table
INSERT INTO Events (visit_id, cookie_id, page_id, event_type, sequence_number, event_time) VALUES
('719fd3', '3d83d3', 5, 1, 4, '2020-03-02 00:29:09.975502'),
('fb1eb1', 'c5ff25', 5, 2, 8, '2020-01-22 07:59:16.761931'),
('23fe81', '1e8c2d', 10, 1, 9, '2020-03-21 13:14:11.745667'),
('ad91aa', '648115', 6, 1, 3, '2020-04-27 16:28:09.824606'),
('5576d7', 'ac418c', 6, 1, 4, '2020-01-18 04:55:10.149236'),
('48308b', 'c686c1', 8, 1, 5, '2020-01-29 06:10:38.702163'),
('46b17d', '78f9b3', 7, 1, 12, '2020-02-16 09:45:31.926407'),
('9fd196', 'ccf057', 4, 1, 5, '2020-02-14 08:29:12.922164'),
('edf853', 'f85454', 1, 1, 1, '2020-02-22 12:59:07.652207'),
('3c6716', '02e74f', 3, 2, 5, '2020-01-31 17:56:20.777383');

Select * from Events;

-- A. Enterprise Relationship Diagram
-- Using the following DDL schema details to create an ERD for all the Clique Bait datasets.
-- Refer Website 

-- B. Digital Analysis 
-- Using the available datasets - answer the following questions using a single query for each one:

-- 1.How many users are there?

SELECT COUNT(DISTINCT user_id) AS total_users
FROM clique_bait.users;

-- 2.How many cookies does each user have on average?

SELECT user_id,AVG(cookie_count) AS avg_cookie_per_user
FROM (
	SELECT user_id, COUNT(DISTINCT cookie_id) AS cookie_count
    FROM clique_bait.users
    GROUP BY user_id
) user_cookies;


-- 3.What is the unique number of visits by all users per month?

SELECT DATE_FORMAT(start_date, '%Y-%m') AS visit_month,
	COUNT(DISTINCT user_id) AS unique_visits
FROM clique_bait.users
GROUP BY DATE_FORMAT(start_date, '%Y-%m');



-- 4.What is the number of events for each event type?
SELECT e.event_type, ei.event_name, COUNT(*) AS event_count
FROM clique_bait.events e
JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name;

-- 5.What is the percentage of visits which have a purchase event?

SELECT 
	(COUNT(DISTINCT CASE WHEN e.event_type = 3 THEN e.visit_id END) * 100.0)/ COUNT(DISTINCT e.visit_id) AS purchase_event_percentage
FROM clique_bait.events e;

-- 6.What is the percentage of visits which view the checkout page but do not have a purchase event?

SELECT 
	(COUNT(DISTINCT CASE WHEN e.event_type = 2 AND NOT EXISTS (
		SELECT 1 FROM clique_bait.events e2 WHERE e2.event_type = 3 AND e2.visit_id = e.visit_id
	) THEN e.visit_id END) * 100.0)/COUNT(DISTINCT e.visit_id) AS checkout_no_purchase_percentage
FROM clique_bait.events e;
    

-- 7.What are the top 3 pages by number of views?

SELECT ph.page_name, COUNT(*) AS view_count
FROM clique_bait.page_hierarchy ph
JOIN clique_bait.events e ON ph.page_id = e.page_id
WHERE e.event_type = 1
GROUP BY ph.page_name
ORDER BY view_count DESC
LIMIT 3;


-- 8.What is the number of views and cart adds for each product category?
SELECT ph.product_category,
	   COUNT(CASE WHEN e.event_type = 1 THEN 1 END) AS views,
       COUNT(CASE WHEN e.event_type = 2 THEN 1 END) AS cart_adds
FROM clique_bait.page_hierarchy ph
JOIN clique_bait.events e ON ph.page_id = e.page_id
GROUP BY ph.product_category;


-- 9.What are the top 3 products by purchases?

-- WRONG SOLUTION 

SELECT ph.product_id, COUNT(*) AS purchase_count
FROM clique_bait.page_hierarchy ph
JOIN clique_bait.events e ON ph.page_id = e.page_id
WHERE e.event_type = 3
GROUP BY ph.product_id
ORDER BY purchase_count DESC 
LIMIT 3;




-- 3. Product Funnel Analysis
-- Using a single SQL query - create a new output table which has the following details:

CREATE TABLE clique_bait.product_funnel AS
SELECT 
	ph.product_id,
    ph.product_category,
    COUNT(CASE WHEN e.event_type = 1 THEN 1 END) AS views,
    COUNT(CASE WHEN e.event_type = 2 THEN 1 END) AS cart_adds,
    COUNT(CASE WHEN e.event_type = 2 AND NOT EXISTS (
		SELECT 1 FROM clique_bait.events e2 WHERE e2.event_type = 3 AND e2.visit_id = e.visit_id
	) THEN 1 END) AS abandoned_cart,
    COUNT(CASE WHEN e.event_type = 3 THEN 1 END) AS purchases
FROM clique_bait.page_hierarchy ph 
JOIN clique_bait.events e ON ph.page_id = e.page_id
GROUP BY ph.product_id, ph.product_category;

SELECT * FROM clique_bait.product_funnel;

-- 1.How many times was each product viewed?
SELECT 
	ph.product_id,
    COUNT(*) AS views
FROM clique_bait.events e
JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
WHERE e.event_type = 1 -- Event Type 1 corresponds to "view" 
GROUP BY ph.product_id;


-- 2.How many times was each product added to cart?

SELECT 
	ph.product_id,
    COUNT(*) AS cart_adds
FROM clique_bait.events e
JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
WHERE e.event_type = 2 -- Event type 2 corresponds to "add to cart"
GROUP BY ph.product_id;


-- 3.How many times was each product added to a cart but not purchased (abandoned)?

SELECT 
	ph.product_id,
    COUNT(*) AS abandoned_cart_adds
FROM clique_bait.events e
JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
WHERE e.event_type = 2 -- Event type 2 corresponds to "add to cart"
AND NOT EXISTS (
	SELECT 1
    FROM clique_bait.events e2
    WHERE e2.visit_id = e.visit_id
		AND e2.page_id = e.page_id
        AND e2.event_type = 3 -- Event type 3 corresponds to "purchase"
)
GROUP BY ph.product_id;


-- 4.How many times was each product purchased?
-- No Output

SELECT 
	ph.product_id,
    COUNT(*) AS purchases
FROM clique_bait.events e
JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
WHERE e.event_type = 3 -- Event type 3 corresponds to "purchase"
GROUP BY ph.product_id;

-- 5.Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
CREATE TABLE clique_bait.category_funnel AS
SELECT 
	product_category,
    SUM(views) AS total_views,
    SUM(cart_adds) AS total_cart_adds,
    SUM(abandoned_cart) AS total_abandoned,
    SUM(purchases) AS total_purchases
FROM clique_bait.product_funnel
GROUP BY product_category;

SELECT * FROM clique_bait.category_funnel;

-- Use your 2 new output tables - answer the following questions:

-- 1.Which product had the most views, cart adds and purchases?
SELECT product_id, MAX(views) AS most_views, MAX(cart_adds) AS most_cart_adds, MAX(purchases) AS most_purchases
FROM clique_bait.product_funnel
GROUP BY product_id
order by most_views desc
limit 1;


-- 2.Which product was most likely to be abandoned?
SELECT product_id, MAX(abandoned_cart) AS most_abandoned
FROM clique_bait.product_funnel
GROUP BY product_id
ORDER BY most_abandoned desc
LIMIT 1;

-- 3.Which product had the highest view to purchase percentage?

SELECT product_id, (purchases * 100.0)/views AS view_to_purchase_percentage
FROM clique_bait.product_funnel
GROUP BY product_id
ORDER BY view_to_purchase_percentage DESC
LIMIT 1;


-- 4.What is the average conversion rate from view to cart add?
-- Conversion Rate = (Cart Adds) / View X 100

SELECT 
	ROUND(AVG(CASE
		WHEN views > 0 THEN (cart_adds / views) * 100
        ELSE 0 
	END),2) AS avg_conversion_rate_view_to_cart_add
FROM product_funnel;


-- 5.What is the average conversion rate from cart add to purchase?
-- Conversion Rate = Purchases/Cart Adds X 100
-- WRONG OUTPUT

SELECT 
	ROUND(AVG(CASE
		WHEN cart_adds > 0 THEN (purchases / cart_adds) * 100
        ELSE 0 
	END),2) AS avg_conversion_rate_cart_add_to_purchase
FROM product_funnel;


-- 3.Campaign Analysis
/* Generate a table that has 1 single row for every unique visit_id record and has the following columns:

* user_id
* visit_id
* visit_start_time: the earliest event_time for each visit
* page_views: count of page views for each visit
* cart_adds: count of product cart add events for each visit
* purchase: 1/0 flag if a purchase event exists for each visit
* campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
* impression: count of ad impressions for each visit
* click: count of ad clicks for each visit
* (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

* Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
* Does clicking on an impression lead to higher purchase rates?
* What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
* What metrics can you use to quantify the success or failure of each campaign compared to eachother? */

-- NO DATA IS ADDED INTO THE TABLE 

CREATE TABLE clique_bait.visit_summary AS
SELECT 	
	u.user_id,
    e.visit_id,
    v.visit_start_time,
    COUNT(CASE WHEN e.event_type = 1 THEN 1 END) AS page_views,
    COUNT(CASE WHEN e.event_type = 2 THEN 1 END) AS cart_adds,
    MAX(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchase, 
    ci.campaign_name,
    COUNT(CASE WHEN e.event_type = 4 THEN 1 END) AS impressions,
    COUNT(CASE WHEN e.event_type = 5 THEN 1 END) AS clicks
FROM clique_bait.events e
JOIN clique_bait.users u ON e.cookie_id = u.cookie_id
JOIN ( 
	SELECT 
		visit_id,
        MIN(event_time) AS visit_start_time
	FROM clique_bait.events
    GROUP BY visit_id
) v ON e.visit_id = v.visit_id
LEFT JOIN clique_bait.campaign_identifier ci 
	ON v.visit_start_time BETWEEN ci.start_date AND ci.end_date
GROUP BY u.user_id, e.visit_id, v.visit_start_time, ci.campaign_name;

SELECT * FROM visit_summary;



-- 1. Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event


-- 2. Does clicking on an impression lead to higher purchase rates?

-- 3. What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?

-- 4. What metrics can you use to quantify the success or failure of each campaign compared to eachother?
-- ERROR 
SELECT 
	ci.campaign_name,
    COUNT(DISTINCT u.user_id) AS total_users,
    SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END ) AS total_purchases,
    (SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) / COUNT(DISTINCT u.user_id))*100 AS purchase_rate,
    SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS total_impressions,
    SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS total_clicks,
    (SUM (CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END)/SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END)) * 100 AS click_through_rate
FROM clique_bait.events e
JOIN clique_bait.users u ON e.cookie_id = u.cookie_id
LEFT JOIN clique_bait.campaign_identifier ci ON e.event_type BETWEEN ci.start_date AND ci.end_date
GROUP BY ci.campaign_name;