-- Who is the senior most employee based on job title ?
SELECT employee_id, last_name, first_name, title, levels FROM employee
ORDER BY levels DESC
LIMIT 1

--Which countries has the most invoices ?
SELECT billing_country, COUNT(*) AS c FROM invoice
GROUP BY billing_country
ORDER BY c DESC

--What are top 3 values of total invoices ?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

-- Write a query that returns that returns one city that has the highest sum of invoice totals.
SELECT billing_city, SUM(total) AS t FROM invoice
GROUP BY billing_city
ORDER BY t DESC
LIMIT 1

-- Write a query that returns the customer who has spent the most money.
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS total
FROM customer
JOIN invoice 
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

/*
Write a query to return email, first name, last name and genre of all Rock Music listeners. Return the list ordered 
alphabetically by email.
*/
SELECT DISTINCT customer.first_name, customer.last_name, customer.email 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
       SELECT track_id FROM track
	   JOIN genre ON track.genre_id = genre.genre_id
       WHERE genre.name LIKE 'Rock')
ORDER BY customer.email

-- Return the artists name and the total track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name, COUNT(artist.name) AS number_of_songs
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
WHERE track_id in (
                   SELECT track.track_id
	               FROM track
                   JOIN genre ON track.genre_id = genre.genre_id
                   WHERE genre.name LIKE 'Rock')
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 1

/*
Return all the track names that have a song length longer than the average song length. Return the name and 
milliseconds for each track. order by the song length with the longest song listed first.
*/
SELECT track.name, track.milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) from track)
ORDER BY milliseconds DESC

/*
Find how much amount spent by each customer on artists? Write a query to return customer name, artist name, and total
spent.
*/
WITH best_selling_artist AS (
	SELECT artist.artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN album ON track.album_id = album.album_id 
	JOIN artist on album.artist_id = artist.artist_id
	GROUP BY artist.artist_id
    ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON il.track_id = t.track_id
JOIN album AS alb ON t.album_id = alb.album_id
JOIN best_selling_artist AS bsa ON alb.artist_id = bsa.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

-- Write a query that returns each country along with the top genre. 
-- We determine the most popular genres as the genre with the highest amount of purchases.
WITH popular_genre AS (
	SELECT customer.country, genre.genre_id, genre.name, COUNT(invoice_line.quantity),
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
	FROM customer
	JOIN invoice ON customer.customer_id = invoice.customer_id 
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY 1,2,3
	ORDER BY 1, 4 DESC
	)
SELECT * FROM popular_genre WHERE RowNo = 1

-- Write a query that returns the country along the top customer and how much they spent.

WITH top_customer AS (
	SELECT customer.country, customer.customer_id, customer.first_name, customer.last_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity), 
	ROW_NUMBER() OVER(
		              PARTITION BY customer.country 
		              ORDER BY (SUM(invoice_line.unit_price*invoice_line.quantity))DESC) AS RowNo
	FROM customer
	JOIN invoice ON customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
	GROUP BY 1,2,3,4
	ORDER BY 1, 5 DESC
)
SELECT * FROM top_customer WHERE RowNo = 1