#10 Sample queries 

# 1) All films with PG-13 films with rental rate of 2.99 or lower
SELECT * 
FROM film f
WHERE f.rental_rate <= 2.99
AND f.rating = 'PG-13';

# 2) All films that have deleted scenes
SELECT f.title, f.special_features, f.release_year
FROM film f
WHERE f.special_features like '%Deleted Scenes%'
AND title like 'c%';

# 3) All active customers
SELECT *
FROM Customer
WHERE active = 1;


# 4) Names of customers who rented a movie on 26th July 2005
SELECT r.rental_id, r.rental_date, r.customer_id,
contact(c.first_name,'',c.last_name) as 'Full name' 
FROM rental r Join customer c on c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-07-26'; 


# 5) Distinct names of customers who rented a movie on 26th July 2005
SELECT DISTINCT r.customer_id,
concat(c.first_name,' ',c.last_name) as 'Full name'
FROM rental r JOIN customer c on c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-07-26';



# H1) How many distinct last names we have in the data?
# 6) How many rentals we do on each day?
SELECT date(rental_date) as d, count(*) 
FROM rental
GROUP BY date(rental_date);

# 7) All Sci-fi films in our catalogue
SELECT * FROM CATEGORY;

SELECT * FROM film_category 
WHERE category_id = 14; 

SELECT fc.film_id, fc.category_id, c.name, f.title, f.release_year 
FROM film_category fc
JOIN category c ON c.category_id = fc.category_id
JOIN film f on f.film_id = fc.film_id
WHERE c.name = 'Sci-Fi';


# 8) Customers and how many movies they rented from us so far?
SELECT r.customer_id, c.first_name, c.email, count(*) as Count
FROM rental r
JOIN customer c on c.customer_id = r.customer_id
GROUP BY r.customer_id
ORDER BY count(*) DESC;

SELECT c.customer_id, c.first_name, c.email, count(r.customer_id)
FROM Customer c
Left Outer Join rental r on c.customer_id = r.customer_id
GROUP BY c.customer_id;

# 9) Which movies should we discontinue from our catalogue (less than 5 lifetime rentals)

WITH low_rentals as
(SELECT i.film_id, count(*)
FROM rental r
JOIN inventory i on i.inventory_id = r.inventory_id
GROUP BY i.film_id
HAVING count(*) <= 5)

SELECT low_rentals.film_id, f.title
FROM low_rentals
JOIN film f on f.film_id = low_rentals.film_id;

# 10) Which movies are not returned yet?

SELECT rental_date, customer_id, i.film_id, f.title
FROM Rental r
JOIN inventory i on i.inventory_id = r.inventory_id
JOIN film f on f.film_id = i.film_id
WHERE r.return_date IS NULL
ORDER BY f.title;

# H1) How many distinct last names we have in the data?
SELECT count(distinct last_name) 
FROM Customer;

# H2) How much money and rentals we make for Store 1 by day?
SELECT date(p.payment_date), sum(p.amount) 
FROM payment p
JOIN rental r on r.rental_id = p.rental_id
JOIN inventory i on i.inventory_id = r.inventory_ida
WHERE i.store_id = 1
GROUP BY date(p.payment_date)
ORDER BY date(p.payment_date);

# What are the three top earning days so far?
SELECT date(p.payment_date), sum(p.amount) 
FROM payment p
JOIN rental r on r.rental_id = p.rental_id 
JOIN inventory i on i.inventory_id = r.inventory_id
WHERE i.store_id = 1
GROUP BY date(p.payment_date)
ORDER BY sum(p.amount) DESC
LIMIT 3;