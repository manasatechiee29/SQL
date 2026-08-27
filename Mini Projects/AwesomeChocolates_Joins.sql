use awesome_chocolates;

-- Select everything from sales table

SELECT *
FROM Sales;

-- Show just a few columns from sales table

SELECT 
	SaleDate, 
    Amount,
    Customers
FROM 
	Sales;
    
SELECT 
	Amount,
    Customers,
    GeoID
FROM
	Sales;
    
-- Adding a calculated column with SQL

SELECT 
	SaleDate,
    Amount,
    Boxes,
    Amount/Boxes 
FROM
	Sales;
    
-- Naming a field with AS in SQL

SELECT 
	SaleDate,
    Amount,
    Boxes,
    Amount / Boxes as 'Amount per box' 
FROM 
	Sales;

-- Using WHERE Clause in SQL

SELECT *
FROM 
	Sales
WHERE 
	AMOUNT > 10000;
    
-- Showing sales data where amount is greater than 10,000 by descending order
SELECT *
FROM 
	Sales
WHERE 
	Amount > 10000
ORDER BY 
	Amount desc;

-- Showing sales data where geography is g1 by product ID &
-- descending order of amounts

SELECT *
FROM 
	Sales
WHERE 
	GeoId = 'g1'
ORDER BY
	PID, Amount desc;
    
-- Working with dates in SQL

SELECT *
FROM 
	Sales
WHERE 
	Amount > 10000
AND 
	SaleDate >= '2022-01-01';
    
-- Using year() function to select all data in a specific year
SELECT 
	SaleDate,
    Amount
FROM 
	Sales
WHERE 
	Amount > 10000 AND YEAR(SaleDate) = '2022'
ORDER BY 
	Amount desc;

-- BETWEEN condition in SQL with < & > operators

SELECT * 
FROM
	Sales
WHERE
	Boxes > 0 AND Boxes <= 50;
    
-- Using the between operator in SQL
SELECT *
FROM 
	Sales
WHERE
	Boxes
BETWEEN 0 AND 50;

-- Using weekday() function in SQL
SELECT 
	SaleDate,
    Amount,
    Boxes,
    Weekday(SaleDate) as 'Day of week'
FROM
	Sales
WHERE 
	Weekday(SaleDate) = 4;
    
-- Working with People table
SELECT *
FROM
	People;
    
-- OR operator in SQL
SELECT *
FROM 
	PEOPLE
WHERE
	TEAM = 'Delish' OR TEAM = 'Juices';
    
-- IN operator in SQL
SELECT * 
FROM 
	People
WHERE 
	TEAM IN ('Delish','Juices');
    
-- LIKE operator in SQL
SELECT *
FROM 
	People
WHERE
	Salesperson LIKE 'B%';
    
SELECT *
FROM 
	People
WHERE
	Salesperson LIKE '%B%';
    
SELECT * FROM Sales;

-- Using CASE to create branching logic in SQL
SELECT 
	SaleDate, Amount,
    CASE 
		WHEN Amount < 1000 THEN 'Under 1k'
		WHEN Amount < 5000 THEN 'Under 5k'
        WHEN Amount < 10000 THEN 'Under 10k'
		ELSE '10k or more'
	END AS 'Amount Category'
FROM Sales;

SELECT 	
	SaleDate, Amount,
    CASE
		WHEN Amount < 10000 THEN 'Under 1k'
		WHEN Amount < 5000 THEN 'Under 5k'
        WHEN Amount < 10000 THEN 'Under 10k'
		else '10k or more'
	END AS 'Amount Category'
FROM Sales;

-- GROUP BY in SQL
SELECT 
	TEAM , count(*)
FROM 
	People
GROUP BY 
	Team;

/* An anti-join is a type of join that retrieves rows from one table that do not have a match in another table. 
In MySQL, anti-joins are typically implemented using a LEFT JOIN with a WHERE clause to check for NULL values 
in the right table or by using a NOT IN or NOT EXISTS approach. */

/* Let's say we want to find the salespersons (SPID) from the People table who did not make any sales 
(i.e., do not appear in the Sales table). */

-- Using LEFT JOIN with NULL Check
SELECT p.SPID, p.Salesperson, p.Team, p.Location
FROM 
	People p 
LEFT JOIN 
	Sales s ON p.SPID = s.SPID
WHERE 
	s.SPID IS NULL;
    
-- USING NOT EXISTS
SELECT 
	p.SPID, p.Salesperson, p.Team, p.Location
FROM 
	People p
WHERE NOT EXISTS (
	SELECT 1
    FROM Sales s
    WHERE p.SPID = s.SPID
);

-- Using NOT IN
SELECT 
	p.SPID, p.Salesperson,p.Team, p.Location
FROM 
	People p
WHERE
	p.SPID NOT IN(	
		SELECT SPID
        FROM Sales
);

