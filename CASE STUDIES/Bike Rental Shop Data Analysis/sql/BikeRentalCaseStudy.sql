USE casestudies;

DROP TABLE IF EXISTS Customer;
CREATE TABLE customer
(
	id int primary key,
    name varchar(30),
    email varchar(50));
    
DROP TABLE IF EXISTS bike;
CREATE TABLE bike
(
	id int primary key,
    model varchar(50),
    category varchar(50),
    price_per_hour decimal,
    price_per_day decimal,
    status varchar(20));
    

DROP table if exists rental;
CREATE TABLE rental
(
 id int primary key,
 customer_id int references customer(id),
 bike_id int references bike(id),
 start_timestamp timestamp,
 duration int,
 total_paid decimal
);


DROP TABLE IF EXISTS membership_type;
CREATE TABLE membership_type
(
	id int primary key,
    name varchar(50),
    description varchar(500),
    price decimal
);


DROP TABLE IF EXISTS membership;
CREATE TABLE membership
(
	id int primary key,
    membership_type_id int references membership_type(id),
    customer_id int references customer(id),
    start_date date,
    end_date date,
    total_paid decimal
);

-- Insert records into Customer table
insert into customer values(1,	'John Doe',			'john.doe@example.com');
insert into customer values(2,	'Alice Smith',		'alice.smith@example.com');
insert into customer values(3,	'Bob Johnson',		'bob.johnson@example.com');
insert into customer values(4,	'Eva Brown',		'eva.brown@example.com');
insert into customer values(5,	'Michael Lee',		'michael.lee@example.com');
insert into customer values(6,	'Sarah White',		'sarah.white@example.com');
insert into customer values(7,	'David Wilson',		'david.wilson@example.com');
insert into customer values(8,	'Emily Davis',		'emily.davis@example.com');
insert into customer values(9,	'Daniel Miller',	'daniel.miller@example.com');
insert into customer values(10,	'Olivia Taylor',	'olivia.taylor@example.com');

-- Insert records into Bike Table
insert into bike values(1,	'Mountain Bike 1'	,'mountain bike'	,10.00	,50.00	,'available');
insert into bike values(2,	'Road Bike 1'	,'road bike',12.00	,60.00	,'available');
insert into bike values(3,	'Hybrid Bike 1'	,'hybrid'	,8.00	,40.00	,'rented');
insert into bike values(4,	'Electric Bike 1'	,'electric',15.00	,75.00	,'available');
insert into bike values(5,	'Mountain Bike 2'	,'mountain bike'	,10.00	,50.00	,'out of service');
insert into bike values(6,	'Road Bike 2'	,'road bike',12.00	,60.00	,'available');
insert into bike values(7,	'Hybrid Bike 2'	,'hybrid'	,8.00	,40.00	,'out of service');
insert into bike values(8,	'Electric Bike 2'	,'electric',15.00	,75.00	,'available');
insert into bike values(9,	'Mountain Bike 3'	,'mountain bike'	,10.00	,50.00	,'rented');
insert into bike values(10,	'Road Bike 3'	,'road bike',12.00	,60.00	,'available');



-- Insert records intp rental Table
Insert into rental values (1, 11,  '2022-11-01 10:00:00', 240, 50.00);
insert into rental values(2,	1,	1,	'2022-11-02 10:00:00',	245,	50.00);
insert into rental values(3,	1,	1,	'2022-11-03 10:00:00',	250,	50.00);
insert into rental values(4,	1,	1,	'2022-11-04 10:00:00',	235,	50.00);
insert into rental values(5,	1,	1,	'2022-12-05 10:00:00',	155,	50.00);
insert into rental values(6,	2,	2,	'2022-12-08 11:00:00',	250,	60.00);
insert into rental values(7,	3,	3,	'2022-12-13 12:00:00',	245,	40.00);
insert into rental values(8,	1,	1,	'2023-01-05 10:00:00',	240,	50.00);
insert into rental values(9,	2,	2,	'2023-01-08 11:00:00',	235,	60.00);
insert into rental values(10,	3,	3,	'2023-02-13 12:00:00',	245,	40.00);
insert into rental values(11,	1,	1,	'2023-03-05 10:00:00',	250,	50.00);
insert into rental values(12,	2,	2,	'2023-03-08 11:00:00',	355,	60.00);
insert into rental values(13,	3,	3,	'2023-04-13 12:00:00',	240,	40.00);
insert into rental values(14,	1,	1,	'2023-04-01 10:00:00',	235,	50.00);
insert into rental values(15,	1,	6,	'2023-05-01 10:00:00',	245,	60.00);
insert into rental values(16,	1,	2,	'2023-05-01 10:00:00',	250,	60.00);
insert into rental values(17,	1,	3,	'2023-06-01 10:00:00',	235,	40.00);
insert into rental values(18,	1,	4,	'2023-06-01 10:00:00',	255,	75.00);
insert into rental values(19,	1,	5,	'2023-07-01 10:00:00',	240,	50.00);
insert into rental values(20,	2,	2,	'2023-07-02 11:00:00',	445,	60.00);
insert into rental values(21,	3,	3,	'2023-07-03 12:00:00',	250,	40.00);
insert into rental values(22,	4,	4,	'2023-08-04 13:00:00',	235,	75.00);
insert into rental values(23,	5,	5,	'2023-08-05 14:00:00',	555,	50.00);
insert into rental values(24,	6,	6,	'2023-09-06 15:00:00',	240,	60.00);
insert into rental values(25,	7,	7,	'2023-09-07 16:00:00',	245,	40.00);
insert into rental values(26,	8,	8,	'2023-09-08 17:00:00',	250,	75.00);
insert into rental values(27,	9,	9,	'2023-10-09 18:00:00',	335,	50.00);
insert into rental values(28,	10,	10,	'2023-10-10 19:00:00',	255,	60.00);
insert into rental values(29,	10,	1,	'2023-10-10 19:00:00',	240,	50.00);
insert into rental values(30,	10,	2,	'2023-10-10 19:00:00',	245,	60.00);
insert into rental values(31,	10,	3,	'2023-10-10 19:00:00',	250,	40.00);
insert into rental values(32,	10,	4,	'2023-10-10 19:00:00',	235,	75.00);


-- Insert into memebership type table
Insert into membership_type values (1, 'Basic Monthly', 'Unlimited rides with non-electric bikes. Renews monthly.', 100.00),
(2,'Basic Annual',	'Unlimited rides with non-electric bikes. Renews annually.',500.00),
(3,'Premium Monthly'	,'Unlimited rides with all bikes. Renews monthly.',	200.00);

-- Insert records into membership table
Insert into membership values (1, 2, 3, '2023-08-01', '2023-08-31', 500.00);
insert into membership values(2,	1,	2,	'2023-08-01',	'2023-08-31',	100.00);
insert into membership values(3,	3,	4,	'2023-08-01',	'2023-08-31',	200.00);
insert into membership values(4,	1,	1,	'2023-09-01',	'2023-09-30',	100.00);
insert into membership values(5,	2,	2,	'2023-09-01',	'2023-09-30',	500.00);
insert into membership values(6,	3,	3,	'2023-09-01',	'2023-09-30',	200.00);
insert into membership values(7,	1,	4,	'2023-10-01',	'2023-10-31',	100.00);
insert into membership values(8,	2,	5,	'2023-10-01',	'2023-10-31',	500.00);
insert into membership values(9,	3,	3,	'2023-10-01',	'2023-10-31',	200.00);
insert into membership values(10,	3,	1,	'2023-11-01',	'2023-11-30',	200.00);
insert into membership values(11,	2,	5,	'2023-11-01',	'2023-11-30',	500.00);
insert into membership values(12,	1,	2,	'2023-11-01',	'2023-11-30',	100.00);


-- Selecting the records from all the different tables
SELECT * FROM customer;
SELECT * FROM bike;
SELECT * FROM rental;
SELECT * FROM membership_type;
SELECT * FROM membership;

-- Problem Statements
-- Following are the business questions that Emily wants answers to. Use SQL to answer them. 

/* 01.Emily would like to know how many bikes the shop owns by category. Can
you get this for her?
Display the category name and the number of bikes the shop owns in
each category (call this column number_of_bikes ). Show only the categories
where the number of bikes is greater than 2 .*/

SELECT 
	category, count(*) AS number_of_bikes
FROM 
	bike
GROUP BY  
	category
HAVING 
	number_of_bikes > 2
ORDER BY 
	number_of_bikes DESC;


/* 2. Emily needs a list of customer names with the total number of
memberships purchased by each.
For each customer, display the customer's name and the count of
memberships purchased (call this column membership_count ). Sort the
results by membership_count , starting with the customer who has purchased
the highest number of memberships.
Keep in mind that some customers may not have purchased any
memberships yet. In such a situation, display 0 for the membership_count . */

SELECT  
	a.name, count(CASE WHEN b.membership_type_id = NULL THEN 0 ELSE b.membership_type_id END) AS membership_count
FROM 
	customer a LEFT JOIN membership b 
ON 
	a.id = b.customer_id
GROUP BY
	a.name
ORDER BY 
	membership_count DESC; 

/* 3. Emily is working on a special offer for the winter months. Can you help her
prepare a list of new rental prices?
For each bike, display its ID, category, old price per hour (call this column
old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old
price per day (call it old_price_per_day ), and discounted price per day (call it
new_price_per_day ).
Electric bikes should have a 10% discount for hourly rentals and a 20%
discount for daily rentals. Mountain bikes should have a 20% discount for
hourly rentals and a 50% discount for daily rentals. All other bikes should
have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits. */


SELECT 
	id, category, price_per_hour as old_price_per_hour, 
-- Case statement for discounted price per hour
CASE
	WHEN category = 'electric' THEN round(price_per_hour - (price_per_hour * 0.10),2) 
    WHEN category = 'mountain bike' THEN round(price_per_hour - (price_per_hour * 0.20),2) 
	ELSE round(price_per_hour - (price_per_hour * 0.50),2)
END AS new_price_per_hour, 
price_per_day as old_price_per_day,
-- Case statement for new price per day
CASE
	WHEN category = 'electric' THEN round(price_per_day - (price_per_day * 0.20),2)
    WHEN category = 'mountain bike' THEN round(price_per_day - (price_per_day * 0.50),2)
    ELSE round(price_per_day - (price_per_day * 0.50),2)
END AS new_price_per_day
FROM bike;

/* 4. Emily is looking for counts of the rented bikes and of the available bikes in
each category.
Display the number of available bikes (call this column
available_bikes_count ) and the number of rented bikes (call this column
rented_bikes_count ) by bike category. */

SELECT category,
	count(CASE WHEN STATUS = 'available' THEN 1 END) AS available_bikes_count,
    count(CASE WHEN STATUS = 'rented' THEN 1  END) AS rented_bikes_count
FROM 
	bike
GROUP BY 
	category;



/* 5. Emily is preparing a sales report. She needs to know the total revenue
from rentals by month, the total by year, and the all-time across all the
years.

Display the total revenue from rentals for each month, the total for each
year, and the total across all the years. Do not take memberships into
account. There should be 3 columns: year , month , and revenue .
Sort the results chronologically. Display the year total after all the month
totals for the corresponding year. Show the all-time total as the last row.
The resulting table looks something like this:
year month revenue
2022 11 200.00
2022 12 150.00
2022 null 350.00
2023 1 110.00
...
2023 10 335.00
2023 null 1370.00
null null 1720.00 */

-- Revenue = Quantity Sold X Price Per Unit	

SELECT 
    YEAR(start_timestamp) AS year,
    MONTH(start_timestamp) AS month,
    SUM(total_paid) AS revenue
FROM rental
GROUP BY YEAR(start_timestamp), MONTH(start_timestamp)

UNION ALL

SELECT 
    YEAR(start_timestamp) AS year,
    NULL AS month,
    SUM(total_paid) AS revenue
FROM rental
GROUP BY YEAR(start_timestamp)

UNION ALL

SELECT 
    NULL AS year,
    NULL AS month,
    SUM(total_paid) AS revenue
FROM rental

ORDER BY year, month;

/* 6. Emily has asked you to get the total revenue from memberships for each
combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this
column membership_type_name ), and the total revenue (call this column
total_revenue ) for every combination of year, month, and membership type.
Sort the results by year, month, and name of membership type. */

SELECT 
	date_format(a.start_date, "%Y") AS year,
    date_format(a.start_date, "%m") AS month,
    b.name AS membership_type_name,
    sum(a.total_paid) AS revenue
FROM 
	membership a JOIN membership_type b 
ON  a.membership_type_id = b.id
GROUP BY year, month, membership_type_name
ORDER BY year, month, membership_type_name;
    

/* 7.Next, Emily would like data about memberships purchased in 2023, with
subtotals and grand totals for all the different combinations of membership
types and months.
Display the total revenue from memberships purchased in 2023 for each
combination of month and membership type. Generate subtotals and
grand totals for all possible combinations. There should be 3 columns:
membership_type_name , month , and total_revenue .
Sort the results by membership type name alphabetically and then
chronologically by month. */

SELECT
	b.name as membership_type_name, 
    date_format(a.start_date, "%m") as month, 
    sum(total_paid) as total_revenue 
FROM 
	membership a 
JOIN
	membership_type b 
ON a.membership_type_id = b.id
GROUP BY 
	membership_type_name
ORDER BY 
	membership_type_name asc, month DESC;
 



/* 8. Now it's time for the final task.
Emily wants to segment customers based on the number of rentals and
see the count of customers in each segment. Use your SQL skills to get
this!
Categorize customers based on their rental history as follows:
Customers who have had more than 10 rentals are categorized as 'more
than 10' .
Customers who have had 5 to 10 rentals (inclusive) are categorized as
'between 5 and 10' .
Customers who have had fewer than 5 rentals should be categorized as
'fewer than 5' .
Calculate the number of customers in each category. Display two columns:
rental_count_category (the rental count category) and customer_count (the
number of customers in each category). */ 

WITH cte AS 
	(SELECT customer_id, count(1),
    CASE WHEN count(1) > 10 THEN 'more than 10'
		 WHEN count(1) BETWEEN 5 AND 10 THEN 'between 5 and 10'
         ELSE 'fewer than 5'
	END AS category
    FROM rental
    GROUP BY customer_id)

SELECT category AS rental_count_category, 
count(*) AS customer_count
FROM 
	cte
GROUP BY 
	category
ORDER BY 
	customer_count;




