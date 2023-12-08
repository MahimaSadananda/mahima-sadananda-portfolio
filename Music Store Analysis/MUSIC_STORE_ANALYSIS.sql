#-------------------------------------------MUSIC STORE ANALYSIS---------------------------------------------


## Sales and Revenue Analysis

# 1) What is the cumulative revenue generated for each music genre?

SELECT  g.name AS top_geners, SUM(i.unit_price * i.quantity) AS total_sales
FROM invoice_line i
JOIN track t on i.track_id = t.track_id
INNER JOIN genre g on g.genre_id = t.genre_id
GROUP BY  top_geners
ORDER BY total_sales desc;

# 2) Identify genres that surpass the average in terms of sales.

SELECT g.name AS genre_name, SUM(l.unit_price * l.quantity) AS sales
FROM invoice_line l
INNER JOIN track t ON t.track_id = l.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY genre_name
HAVING sales > (SELECT AVG(sales) FROM (
    SELECT g.name AS genre_name, SUM(l.unit_price * l.quantity) AS sales
    FROM invoice_line l
INNER JOIN track t ON t.track_id = l.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY genre_name
) AS avg_sales)
ORDER BY sales DESC;

# 3) Which tracks have the highest total sales?

SELECT t.name AS track_name , SUM(i.unit_price * i.quantity) AS sales
FROM invoice_line i
INNER JOIN track t ON t.track_id = i.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY track_name
ORDER BY sales desc;

# 4)What is the sales data breakdown on a monthly basis?

SELECT MONTH(invoice_date) AS month, SUM(total) AS sales
FROM invoice
GROUP BY month;

# 5) Using a window function, can you analyze the last year quarterly sales trend for each genre and identify genres that 
-- consistently rank among the top three in sales?

WITH genre_quaterly AS (
SELECT g.name AS genre_name, quarter(i.invoice_date) AS quarterly, SUM(l.unit_price * l.quantity) AS total_sales
FROM invoice i
INNER JOIN invoice_line l ON i.invoice_id = l.invoice_id
INNER JOIN track t ON t.track_id = l.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
WHERE YEAR(invoice_date) = 2020
GROUP BY genre_name, quarterly)

SELECT genre_name, quarterly, total_sales ,
		RANK() OVER (PARTITION BY quarterly ORDER BY total_sales DESC) rank_totalsales
FROM genre_quaterly;


#-------------------------------------------------------------------------------------------------------

## Customer Behavior Analysis:

# 1) How many customers are there in each country, and what is the count for each country?

SELECT  COUNT(distinct(c.customer_id)) AS customers, c.country AS country
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY customers;

#2) Identify countries where the number of customers constitutes more than 10% of the total customer base.

SELECT country, COUNT(customer_id) AS customers
FROM customer
GROUP BY country
HAVING customers > (SELECT 0.1 * SUM(customers)
		FROM (SELECT country, COUNT(customer_id) AS customers
FROM customer
GROUP BY country)
		AS subquery)
ORDER BY customers desc;

# 3) Determine the average amount spent per customer.

SELECT Distinct(c.customer_id), AVG(i.total) AS money_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id;

# 4) Analyze and compare the average spending per customer across various countries.

SELECT Distinct(c.country), AVG(i.total) AS money_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country;

# 5) What are top 3 values of total invoice?

SELECT total AS Total_Invoice
FROM invoice
GROUP BY total
ORDER BY total DESC
LIMIT 3;

# 6)  Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money

SELECT c.customer_id, concat(c.first_name, " " , c.last_name) AS Best_Customer, SUM(i.total) AS high_total
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY Best_Customer, c.customer_id
ORDER BY high_total desc
LIMIt 1;


#-------------------------------------------------------------------------------------------------------


## Genre and Artist Popularity:

# 1)  Among the artists in the music store, which one has the highest total sales in terms of revenue?

SELECT  a.name AS artist_name, SUM(i.unit_price * i.quantity) AS total_sales
FROM invoice_line i
JOIN track t ON i.track_id = t.track_id
INNER JOIN album2 l ON l.album_id = t.album_id
INNER JOIN artist a ON a.artist_id = l.artist_id
GROUP BY  artist_name
ORDER BY total_sales desc
LIMIT 5;

# 2) What are the top 5 genres based on total sales.

SELECT  g.name AS top_geners, SUM(i.unit_price * i.quantity) AS total_sales
FROM invoice_line i
JOIN track t on i.track_id = t.track_id
INNER JOIN genre g on g.genre_id = t.genre_id
GROUP BY  top_geners
ORDER BY total_sales desc
LIMIT 5;

# 3) Identify the genre with the highest number of tracks.

SELECT g.name AS genre_name, COUNT(t.track_id) AS tracks_record
FROM track t
INNER JOIN genre g ON t.genre_id = g.genre_id
GROUP BY genre_name
ORDER BY tracks_record desc;

# 4) Who are the top-selling artists in the "Rock" genre based on total sales?

SELECT r.name AS artist_name, SUM(l.unit_price * l.quantity) AS total_sales
FROM invoice_line l
JOIN track t ON t.track_id = l.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album2 a ON a.album_id = t.album_id
JOIN artist r ON r.artist_id = a.artist_id
WHERE  g.name = "Rock"
GROUP BY artist_name
ORDER BY total_sales desc;


#-------------------------------------------------------------------------------------------------------

## Employee Analysis

# 1) How can I retrieve sales data for each employee?

SELECT CONCAT(e.first_name, e.last_name) AS employe_name, SUM(i.total) AS sales, e.title
FROM employee e
INNER JOIN customer c ON c.support_rep_id = e.employee_id
INNER JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY employe_name, e.title
ORDER BY sales;

# 2) How can I display the reporting relationships within the employee hierarchy? {*****}

SELECT 
	    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
		e.reports_to AS manager_id,
        CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM 
    employee e
LEFT JOIN 
    employee m ON e.reports_to = m.employee_id;


# 3) Identify employees who report to the same manager. {******}

        
SELECT
    e.reports_to AS manager_id,
    CONCAT(m.first_name, " ", m.last_name) AS manager_name,
    GROUP_CONCAT(CONCAT(e.first_name, " ", e.last_name) ORDER BY e.employee_id) AS employees_reported
FROM
    employee e
JOIN
    employee m ON e.reports_to = m.employee_id
WHERE
    e.employee_id >1
GROUP BY
    manager_id, manager_name
ORDER BY
    manager_id;
    
# 4) Who is the senior most employee based on job title?

SELECT 
	levels,
    CONCAT(First_name, " ", last_name) AS employee_name,
    title AS job_title
FROM 
	employee
WHERE 
	reports_to IS NULL
ORDER BY levels desc;


#-------------------------------------------------------------------------------------------------------

## Global Trends

# 1) What is the total revenue generated by each country?

SELECT billing_country AS country, SUM(total) AS revenue_generated
FROM invoice
GROUP BY country;

# 2) What is the genre that has the highest total sales in a USA?

SELECT  g.name AS genres_name, SUM(l.unit_price * l.quantity) AS total_sales, i.billing_country AS Country_name
FROM invoice i
INNER JOIN invoice_line l on i.invoice_id = l.invoice_id
INNER JOIN track t on t.track_id = l.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY genres_name, Country_name
HAVING i.billing_country = "USA"
ORDER BY total_sales desc;

# 3) How do the total sales of rock music in the USA compare to those in Canada?

SELECT  g.name AS genres_name, SUM(l.unit_price * l.quantity) AS total_sales, i.billing_country AS Country_name
FROM invoice i
INNER JOIN invoice_line l on i.invoice_id = l.invoice_id
INNER JOIN track t on t.track_id = l.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY genres_name, Country_name
HAVING (i.billing_country = "USA" OR i.billing_country = "Canada") AND genres_name = "Rock"
ORDER BY total_sales desc;

# 4) What are the top three cities with the highest number of customers ?

SELECT city, COUNT(customer_id) AS Customer
FROM Customer
GROUP BY city
ORDER BY Customer desc
LIMIT 3;

# 5) Which countries have the most Invoices?

SELECT count(billing_country) AS Num_invoices, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY Num_invoices DESC;

# 6) We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 

SELECT country, MAX(genre) as "popular_genre"
FROM (
    SELECT i.billing_country as "country", g.name as "genre", SUM(i.total) as "total_amount"
    FROM invoice i 
    JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
    JOIN track t
    ON il.track_id = t.track_id
    JOIN genre g
    ON t.genre_id = g.genre_id
    GROUP BY country, g.name
) as subquery
GROUP BY country
ORDER BY country;



#-------------------------------------------------------------------------------------------------------

## Top Playlists

# 1) Identify playlists with most tracks  

SELECT y.name AS playlist_name, COUNT(t.track_id) AS most_tracks
FROM track t 
INNER JOIN playlist_track p ON p.track_id = t.track_id
INNER JOIN playlist y ON y.playlist_id = p.playlist_id
GROUP BY playlist_name
ORDER BY most_tracks desc;

# 2) Determine the top playlists created by users

SELECT y.name AS top_playlist, SUM(i.unit_price * i.quantity) AS sales
FROM invoice_line i
JOIN track t on t.track_id = i. track_id
JOIN playlist_track p ON p.track_id = t.track_id
JOIN playlist y ON y.playlist_id = p.playlist_id
GROUP BY top_playlist
ORDER BY sales desc;

# 3) What are the top 10 tracks in a rocks genre based on total sales?

SELECT t.name AS track_name , SUM(i.unit_price * i.quantity) AS sales
FROM invoice_line i
INNER JOIN track t ON t.track_id = i.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = "Rock"
GROUP BY track_name
ORDER BY sales desc
LIMIT 10;

# 4) Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name, milliseconds 
FROM track
WHERE milliseconds > (SELECT avg(milliseconds)FROM track)
ORDER BY milliseconds DESC;


























