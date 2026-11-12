Create database DannysCaseStudy;

use DannysCaseStudy;
-- Case Study 01
-- Step 1: Create the table
Create table sales(
	customer_id char(1),
    order_date date,
    product_id int
);

-- Step 2: Insert the records into the table
INSERT INTO sales (customer_id, order_date, product_id) VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);



-- Step 1: Create the table
Create table menu(
	product_id int primary key,
    product_name varchar(50),
    price decimal(10,2));
    
-- Step 2: Insert the records into the table
INSERT INTO menu(product_id, product_name, price) VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);

-- Step 1: Create the table
create table members(
	customer_id char(1) primary key,
    join_date date
);

-- Step 2: Insert the records into the table
insert into members (customer_id, join_date) VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

-- Executing complete tables
Select * from sales;
Select * from menu;
Select * from members;

-- Case Study Questions
-- Each of the following case study questions can be answered using a single SQL statement:
use DannysCaseStudy;
show tables;

-- 1. What is the total amount each customer spent at the restaurant?
Select a.customer_id, sum(b.price) as overall_price
from sales a join menu b 
on a.product_id = b.product_id
group by a.customer_id;
	

-- 2.How many days has each customer visited the restaurant?
Select customer_id , count(distinct(order_date)) as order_days
from sales
group by customer_id; 


-- 3.What was the first item from the menu purchased by each customer?
With Rank1 as
( 
Select s.customer_id,
		M.product_name,
        s.order_date,
        dense_Rank() over (partition by s.customer_id order by s.order_date) as rnk
from menu m
join sales s
on m.product_id = s.product_id
group by s.customer_id, m.product_name, s.order_date
)
Select customer_id, product_name
from Rank1
where rnk = 1;

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
Select a.product_name, count(b.product_id)
from menu a join sales b 
on a.product_id = b.product_id
group by a.product_name
order by count(b.product_id) desc
limit 1;

-- or 

Select a.product_name, count(b.order_date) as orders
from menu a join sales b 
on a.product_id = b.product_id
group by a.product_name
order by orders desc
limit 1;


-- 5.Which item was the most popular for each customer?
with rnk as
( 
Select s.customer_id, 
		M.product_name,
        count(s.product_id) as count,
        dense_rank() over (partition by s.customer_id order by count(s.product_id) desc) as rank1
from menu m 
join sales s
on m.product_id = s.product_id
group by s.customer_id, s.product_id, m.product_name
)

Select customer_id, product_name, count
from rnk
where rank1 =1; 

-- 6. Which item was purchased first by the customer after they became a member?
with rank1 as
( 
Select s.customer_id,
	   m.product_name,
       dense_rank() over (partition by s.customer_id order by s.order_date) as rnk
from sales s
join menu m 
on m.product_id = s.product_id
join members mem
on mem.customer_id = s.customer_id 
where s.order_date >= mem.join_date
)

Select * 
from rank1
where rnk = 1;

-- 7.Which item was purchased just before the customer became a member?
With rank1 as
(
Select s.customer_id,
		m.product_name,
        dense_rank() over (partition  by s.customer_id order by s.order_date) as rnk
from sales s
join menu m
on m.product_id = s.product_id
join members mem
on mem.customer_id = s.customer_id
where s.order_date < mem.join_date
)

Select customer_id, product_name
from rank1
where rnk = 1;

-- 8.What is the total items and amount spent for each member before they became a member?
Select a.customer_id, sum(b.price) as total_price, count(a.product_id) as total_items
from sales a join menu b
on a.product_id  = b.product_id
join members c on a.customer_id = c.customer_id
where a.order_date < join_date
group by a.customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each 
-- customer have?
with points as(
	Select *, case when product_id = 1 then price *20 
				else price * 10
                end as points
	from menu)
    
Select s.customer_id, sum(p.points) as points
from sales s
join points p 
on p.product_id = s.product_id
group by s.customer_id;




-- 10th is Wrong answer need to update it properly
/* 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all 
 items, not just sushi - how many points do customer A and B have at the end of January? */

Select
	s.customer_id,
    sum(case
			when (datediff(day, me.join_date, s.order_date) between 0 and 7) or (m.product_id = 1) then m.price * 20
            else m.price * 10
		end) as Points
 from members as me
	inner join sales as s on s.customer_id = me.customer_id
    inner join menu as m on m.product_id = s.product_id
where s.order_date >= me.join_date and s.order_date <= cast('2021-01-31' as DATE)
group by s.customer_id;

-- Bonus Question
-- 1.Recreating the table
Select 
	s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    case	
		when mem.join_date is not null and s.order_date >= mem.join_date then 'Y'
        else 'N'
	end as member
from 
	sales s
join 
	menu m 
    on s.product_id = m.product_id
left join 
	members mem
    on s.customer_id  = mem.customer_id
order by 
	s.customer_id, s.order_date, m.product_name;


-- Danny also requires further information about the ranking of customer products, but he purposely does not need
-- the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

Select 
	s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    case
		when mem.join_date is not null and s.order_date >= mem.join_date then 'Y'
        else 'N'
	END AS member,
    CASE
		when mem.join_date is not null and s.order_date >= mem.join_date then
			rank() over (partition by s.customer_id order by s.order_date, m.product_name)
		else null
	end as ranking
from 
	sales s
join 
	menu m
    on s.product_id = m.product_id
left join
	members mem
    on s.customer_id = mem.customer_id
order by 
	s.customer_id, s.order_date, m.product_name;