CREATE SCHEMA pizza_runner;
-- SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
-- Executing the Tables
Select * from runners;
Select * from customer_orders;
Select * from runner_orders;
select * from pizza_names;
Select * from pizza_recipes;
SELECT * FROM pizza_toppings;

-- Data Clearning
-- Link : https://github.com/manaswikamila05/8-Week-SQL-Challenge/blob/main/Case%20Study%20%23%202%20-%20Pizza%20Runner/0.%20Data%20Clean.md

DROP Table if exists customer_orders_temp;

create temporary table customer_orders_temp as
select order_id,
		customer_id,
        pizza_id,
        case
			when exclusions = '' then NULL
            when exclusions = 'null' then null
            else exclusions
		end as exclusions,
        case
			when extras = '' then NULL
            when extras = 'null' then NULL
            ELSE extras
		END as extras,
        order_time
from customer_orders;

Select * FROM customer_orders_temp;

Drop table if exists runner_orders_temp;

create temporary table runner_orders_temp as
Select order_id, 
		runner_id,
        case
			WHEN pickup_time LIKE 'null' THEN NULL 
            else pickup_time
		end as pickup_time,
        case
			when distance like 'null' THEN NULL
            ELSE CAST(regexp_replace(distance, '[a-z]+','') as FLOAT)
		END AS distance,
        CASE
			WHEN duration LIKE 'null' THEN NULL
            ELSE CAST(regexp_replace(duration, '[a-z]+','') as FLOAT)
		end as duration,
        CASE
			WHEN cancellation LIKE '' THEN NULL
            WHEN cancellation LIKE 'null' THEN NULL
            ELSE cancellation
		END as cancellation
from runner_orders;

Select * from runner_orders;

-- Expanding the comma separated string into rows
Select *,
	json_array(toppings),
    replace(json_array(toppings),',','","'),
    trim(replace(json_array(toppings),',','","'))
FROM pizza_runner.pizza_recipes;

SELECT t.pizza_id, (j.topping)
FROM pizza_recipes t
JOIN json_table(trim(replace(json_array(t.toppings), ',','","')), '$[*]' columns(topping varchar(50) PATH '$')) j;

Select t.order_id,
		t.customer_id,
        t.pizza_id,
        trim(j1.exclusions) as exclusions,
        trim(j2.extras) as extras,
        t.order_time
from customer_orders_temp t 
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',','","')),'$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras),',','","')), '$[*]' columns (extras varchar(50) PATH '$')) j2;


-- A. Pizza Metrics
-- 1.How many pizzas were ordered?
use pizza_runner;
Select count(pizza_id) as pizzas_orders
from customer_orders;

-- 2.How many unique customer orders were made?
Select count(distinct customer_id) as unique_customer_order
from customer_orders;

-- 3.How many successful orders were delivered by each runner?
Select runner_id, count(order_id) as delivered_orders
from runner_orders_temp
where cancellation is null
group by runner_id;

-- 4.How many of each type of pizza was delivered?
Select pizza_id,
		pizza_name,
        count(pizza_id) as 'Number of Pizzas Delivered'
from pizza_runner.runner_orders_temp
INNER JOIN customer_orders_temp using (order_id)
INNER JOIN pizza_names using (pizza_id)
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
Select a.customer_id, 
count(case when b.pizza_name = 'Meat Lovers' then 1 else 0 end) as "Meat Food Counts",
count(case when b.pizza_name = 'Vegetarian' then 1 else 0 end) as "Vegetarian Counts"
from customer_orders_temp a join pizza_names b 	
on  a.pizza_id = b.pizza_id
group by a.customer_id
order by a.customer_id;

-- 6.What was the maximum number of pizzas delivered in a single order?
Select a.runner_id, b.customer_id, c.pizza_id, count(a.pickup_time) as "successful_orders"
from runner_orders_temp  a join customer_orders_temp b using(order_id) 
join pizza_names c using(pizza_id)
where a.cancellation is null
group by runner_id
order by successful_orders desc limit 1 ;

-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
Select 
	co.customer_id,
    sum(case
			when (co.exclusions is not null or co.extras is not null) then 1
            else 0 end) as pizzas_with_changes,
	sum(case	
			when (co.exclusions is null and co.extras is null) then 1
            else 0 
		end) as pizzas_without_changes
from 
	customer_orders_temp co
Join 
	runner_orders_temp ro on co.order_id = ro.order_id
where
	ro.cancellation is null -- Only consider orders that were delivered
group by 
	co.customer_id
order by 
	co.customer_id;

-- 8.How many pizzas were delivered that had both exclusions and extras?
Select a.customer_id,
-- 	count(b.runner_id) as delivered_pizzas,
	sum(case
			when (a.exclusions IS NOT NULL 
				OR a.extras IS NOT NULL) THEN 1
			ELSE 0 
		END) as change_in_pizza
from customer_orders_temp a
INNER JOIN runner_orders_temp b using (order_id)
WHERE b.cancellation IS NULL 
GROUP BY a.customer_id
order by a.customer_id;

-- 9.What was the total volume of pizzas ordered for each hour of the day?
Select hour(order_time) as 'Hour',
	count(order_id) as 'Number of Pizzas ordered',
    round(100 * count(order_id)/sum(count(order_id)) over (),2) as 'Volume of pizzas ordered'
from pizza_runner.customer_orders_temp
group by 1
order by 1;


-- 10.What was the volume of orders for each day of the week?
Select dayname(order_time) as 'Day Of Week',
	count(order_id) as 'Number of pizzas ordered',
    round(100 * count(order_id)/sum(count(order_id)) over(), 2) as 'Volume of pizzas ordered'
from pizza_runner.customer_orders_temp
group by 1
order by 2 desc;

-- B.Runner and Customer Experience 
-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Select week(registration_date) as 'Week of registration',
	count(runner_id) as 'Number of runners'
from pizza_runner.runners
group by 1;


-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Select runner_id,
	timestampdiff(minute, order_time, pickup_time) as runner_pickup_time,
    round(avg(timestampdiff(minute, order_time, pickup_time)),2) as avg_runner_pickup_time
from runner_orders_temp
INNER JOIN customer_orders_temp using (order_id)
where cancellation is NULL
group by runner_id;

-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
with order_count_cte as 
	(Select order_id,
			count(order_id) as pizzas_order_count,
            TIMESTAMPDIFF(MINUTE, order_time, pickup_time) as prep_time
	from runner_orders_temp
    INNER JOIN customer_orders_temp using (order_id)
    WHERE cancellation IS NULL
    GROUP BY order_id)

Select pizzas_order_count,
	round(avg(prep_time),2)
from order_count_cte
group by pizzas_order_count;

-- 4.What was the average distance travelled for each customer?
Select customer_id,
		round(avg(distance),2) as 'average_distance_travelled'
from runner_orders_temp
INNER JOIN customer_orders_temp using (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id;

-- 5.What was the difference between the longest and shortest delivery times for all orders?
Select min(duration) as minimum_duration,
	max(duration) as maximum_duration,
    max(duration) - min(duration) as maximum_difference
from runner_orders_temp;

-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
Select runner_id,
		distance as distance_km,
        round(duration/60,2) as duration_hr,
        round(distance*60/duration,2) as average_speed
from runner_orders_temp
where cancellation IS NULL
ORDER BY runner_id;

-- 7.What is the successful delivery percentage for each runner? 
Select runner_id,
	count(pickup_time) as delivered_orders,
    count(*) as total_orders,
    round(100 * count(pickup_time)/count(*)) as delivery_success_percentage
from runner_orders_temp
group by runner_id
order by runner_id;

-- C.Ingredient Optimisation
-- Temporary tables created to solve the below queries
DROP TABLE row_split_customer_orders_temp;

CREATE
TEMPORARY TABLE row_split_customer_orders_temp as
SELECT t.row_num,
		t.order_id,
        t.customer_id,
        t.pizza_id,
        trim(j1.exclusions) as exclusions,
        trim(j2.extras)  as extras,
        t.order_time
from 
	(Select *,
			row_number() over() as row_num
	from customer_orders_temp) as t 
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',','","')),
					'$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras),',','","')),
					'$[*]' columns (extras varchar(50) PATH '$')) j2;
                    
SELECT *
FROM row_split_customer_orders_temp;

DROP TABLE row_split_pizza_recipes_temp;

CREATE
TEMPORARY TABLE row_split_pizza_recipes_temp as
SELECT t.pizza_id,
		trim(j.topping) as topping_id
from pizza_recipes t
join json_table(trim(replace(json_array(t.toppings),',','","')),
				'$[*]' columns (topping varchar(50) PATH '$')) j;

SELECT *
FROM row_split_pizza_recipes_temp;

DROP TABLE IF EXISTS standard_ingredients;

CREATE
TEMPORARY TABLE standard_ingredients as
SELECT pizza_id,
		pizza_name,
        group_concat(DISTINCT topping_name) 'standard_ingredients'
FROM row_split_pizza_recipes_temp
INNER JOIN pizza_names USING (pizza_id)
INNER JOIN pizza_toppings USING (topping_id)
GROUP BY pizza_name
ORDER BY pizza_id;

SELECT *
FROM standard_ingredients;

-- 1.What are the standard ingredients for each pizza?
Select *
FROM standard_ingredients;

-- 2.What was the most commonly added extra?
WITH extra_count_cte as
	(SELECT trim(extras) as extra_topping,
			count(*) as purchase_counts
	FROM row_split_customer_orders_temp
    WHERE extras IS NOT NULL
    GROUP BY extras)
    
SELECT topping_name,
		purchase_counts
FROM extra_count_cte
INNER JOIN pizza_toppings ON extra_count_cte.extra_topping = pizza_toppings.topping_id
LIMIT 1;

-- 3.What was the most common exclusion?
WITH extra_count_cte as
	(SELECT trim(exclusions) AS extra_topping,
			count(*) AS purchase_counts
	FROM row_split_customer_orders_temp
    WHERE exclusions IS NOT NULL
    GROUP BY exclusions)
    
SELECT topping_name,
		purchase_counts
FROM extra_count_cte
INNER JOIN pizza_toppings ON extra_count_cte.extra_topping = pizza_toppings.topping_id
LIMIT 1;

/* 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
 Meat Lovers
 Meat Lovers - Exclude Beef
 Meat Lovers - Extra Bacon
 Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */
 
 WITH order_summary_cte AS
	(SELECT pizza_name,
			row_num,
            order_id,
            customer_id,
            excluded_topping,
            t2.topping_name as extras_topping
	FROM
		(SELECT *,
				topping_name as excluded_topping
		FROM row_split_customer_orders_temp
        LEFT JOIN standard_ingredients USING (pizza_id)
        LEFT JOIN pizza_toppings ON topping_id = exclusions) t1
	LEFT JOIN pizza_toppings t2 on t2.topping_id = extras)
SELECT order_id,
		customer_id,
        CASE
			WHEN excluded_topping IS NULL
				AND extras_topping IS NULL THEN pizza_name
			WHEN extras_topping IS NULL
				AND excluded_topping IS NOT NULL THEN concat(pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
            WHEN excluded_topping IS NULL
				AND extras_topping IS NOT NULL THEN concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping))
			ELSE concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping), ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
		END AS order_item
	FROM order_summary_cte
    GROUP BY row_num;

 
 
-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

SELECT 
    co.order_id,
    pn.pizza_name,
    GROUP_CONCAT(CASE 
                     WHEN FIND_IN_SET(pt.topping_id, co.extras) > 0 THEN CONCAT('2x', pt.topping_name)
                     ELSE pt.topping_name 
                 END ORDER BY pt.topping_name ASC) AS ingredient_list
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.order_id, pn.pizza_name;


-- 6.For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"




-- 7.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT 
    pt.topping_name,
    COUNT(*) AS total_quantity
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
WHERE ro.cancellation IS NULL
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;



-- D.Pricing and Ratings
-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
    SUM(CASE 
            WHEN pn.pizza_name = 'Meat Lovers' THEN 12 
            WHEN pn.pizza_name = 'Vegetarian' THEN 10 
        END) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;



/* 2.What if there was an additional $1 charge for any pizza extras?
  Add cheese is $1 extra */
  
 SELECT 
    SUM(CASE 
            WHEN pn.pizza_name = 'Meat Lovers' THEN 12 
            WHEN pn.pizza_name = 'Vegetarian' THEN 10 
        END + 
        (CASE 
            WHEN co.extras IS NOT NULL THEN LENGTH(co.extras) - LENGTH(REPLACE(co.extras, ',', '')) + 1
            ELSE 0
        END)) AS total_revenue_with_extras
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;
 
  
  
-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
CREATE TABLE runner_ratings (
    order_id INTEGER,
    runner_id INTEGER,
    customer_id INTEGER,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    PRIMARY KEY (order_id, runner_id)
);

-- Example data
INSERT INTO runner_ratings (order_id, runner_id, customer_id, rating) VALUES
(1, 101, 201, 5),
(2, 102, 202, 4),
(3, 101, 203, 3);





/* 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
 customer_id
 order_id
 runner_id
 rating
 order_time
 pickup_time
 Time between order and pickup
 Delivery duration
 Average speed
 Total number of pizzas */
 
 SELECT 
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_between_order_and_pickup,
    TIME_TO_SEC(ro.duration)/60 AS delivery_duration_minutes,
    ROUND(ro.distance / (TIME_TO_SEC(ro.duration)/3600), 2) AS average_speed,
    COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN runner_ratings rr ON co.order_id = rr.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.distance, ro.duration;

 
 
 
/* 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per 
 kilometre traveled - how much money does Pizza Runner have left over after these deliveries? */
WITH RunnerCosts AS (
    SELECT 
        SUM(ro.distance * 0.30) AS total_runner_payment
    FROM runner_orders ro
    WHERE ro.cancellation IS NULL
)
SELECT 
    (SELECT SUM(CASE 
                   WHEN pn.pizza_name = 'Meat Lovers' THEN 12 
                   WHEN pn.pizza_name = 'Vegetarian' THEN 10 
               END)
     FROM customer_orders co
     JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
     JOIN runner_orders ro ON co.order_id = ro.order_id
     WHERE ro.cancellation IS NULL) - 
    (SELECT total_runner_payment FROM RunnerCosts) AS net_revenue;
 
 
 
 
-- E.Bonus Questions
/* If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement 
 to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu? */
 
-- Insert a new pizza type
INSERT INTO pizza_names (pizza_id, pizza_name) VALUES (3, 'Supreme');

-- Insert toppings for Supreme pizza
INSERT INTO pizza_recipes (pizza_id, toppings) VALUES 
(3, (SELECT GROUP_CONCAT(topping_id) FROM pizza_toppings));
