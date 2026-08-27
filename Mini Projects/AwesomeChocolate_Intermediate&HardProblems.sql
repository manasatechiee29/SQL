use awesome_chocolates;

/* 
In the above data, a shipment refers to the delivery of a specific 
product (identified by the PID) to a geographic region (GeoId) by a salesperson (SPID) 
on a specific date (SaleDate).
*/

-- INTERMEDIATE PROBLEMS
-- 1. Print details of shipments (sales) where amounts are > 2,000 and boxes are <100?
SELECT *
FROM Sales
WHERE Amount > 2000 AND Boxes < 100;


-- 2. How many shipments (sales) each of the sales persons had in the month of January 2022?
SELECT b.Salesperson, count(a.SPID) as shipments
FROM Sales a JOIN People b 
ON a.SPID = b.SPID
WHERE month(a.SaleDate) = '1' and year(a.SaleDate) = '2022'
GROUP BY 1
ORDER BY 2 desc;


-- 3. Which product sells more boxes? Milk Bars or Eclairs? Milk Bars , Eclairs
SELECT a.product, sum(b.boxes) as Total_Sales 
FROM products a join sales b using(PID)
WHERE a.product IN ("Milk Bars","Eclairs")
GROUP BY a.product
ORDER BY Total_Sales DESC 
LIMIT 1;


-- 4. Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
SELECT a.product, sum(b.boxes) as Total_Sales 
FROM products a join sales b using(PID)
WHERE a.product IN ("Milk Bars","Eclairs") AND b.SaleDate between '2022-02-01' and '2022-02-07'
GROUP BY a.product
ORDER BY Total_Sales DESC 
LIMIT 1;

-- OR 

select pr.product, sum(boxes) as 'Total Boxes'
from sales s
join products pr on s.pid = pr.pid
where pr.Product in ('Milk Bars', 'Eclairs')
and s.saledate between '2022-2-1' and '2022-2-7'
group by pr.product;


-- 5. Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?
SELECT *,
	CASE
		WHEN WEEKDAY(SaleDate) = 2 THEN 'Wednesday Shipment'
        ELSE NULL
	END AS W_Shipment
FROM Sales
WHERE Customers < 100
	AND boxes < 100
    AND WEEKDAY(SaleDate) = 2;

-- HARD PROBLEMS
-- 1. What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
SELECT Count(*)
FROM Sales S
JOIN People p ON p.SPID = S.SPID
WHERE S.SaleDate between '2022-01-01' and '2022-01-07';

-- 2. Which salespersons did not make any shipments in the first 7 days of January 2022?
Select p.salesperson
from People p 
where p.spid not in 
(Select distinct s.spid from sales s where s.SaleDate between '2022-01-01' and '2022-01-07');



-- 3. How many times we shipped more than 1,000 boxes in each month?
SELECT 
	Year(SaleDate, '%Y') AS Years,
	date_format(SaleDate,'%M') AS MonthName,
    Count(*) as 'Times we shipped 1k boxes'
FROM Sales
GROUP BY 
	monthname
HAVING 
	SUM(boxes) > 1000
ORDER BY 
	MONTH(SaleDate) ASC;
    
-- OR

SELECT 
	MONTHNAME(SaleDate) AS MonthName,
    Count(distinct PID) as shipment
FROM Sales
GROUP BY 
	monthname
HAVING 
	SUM(boxes) > 1000
ORDER BY 
	MONTH(SaleDate) ASC;


-- OR 

SELECT YEAR(SALEDATE) 'YEAR', 
		MONTH(SaleDate) 'Month',
        Count(*) 'Times we shipped 1k boxes'
FROM Sales
	where boxes > 1000
    group by year(saledate), month(saledate)
    order by year(saledate), month(saledate);


-- 4. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
-- Setting Variables
Set @product_name = 'After Nines';
Set @country_name = 'New Zealand';

Select year(SaleDate) 'Year', Month(SaleDate) as 'Month',
if(sum(boxes) > 1, 'Yes', 'No') AS 'Status'
FROM Sales s
JOIN Products pr ON pr.PID = s.PID
JOIN Geo g ON g.GeoID  = s.GeoID
where pr.Product = @product_name and g.Geo = @country_name -- Filtering Data
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

-- 5. India or Australia? Who buys more chocolate boxes on a monthly basis?
SELECT YEAR(SaleDate) as 'Year', Month(SaleDate) as 'Month',
SUM(CASE WHEN g.Geo = 'India' = 1 THEN boxes ELSE 0 END) AS 'India Boxes',
SUM(CASE WHEN g.Geo = 'Australia' = 1 THEN boxes ELSE 0 END) AS 'Australia Boxes'
FROM Sales s
JOIN Geo g on g.GeoID = s.GeoID
GROUP BY Year(Saledate), month(Saledate)
ORDER BY Year(Saledate), month(Saledate);


