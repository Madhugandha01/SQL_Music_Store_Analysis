create Database muicstore;
/* Q1: Who is the senior most employee based on job title? */
select * from employee 
order by levels desc 
limit 1;

/* Q2: Which countries have the most Invoices? */
select count(*) as c , billing_country
from invoice
group by billing_country
order by c desc;

/* Q3: What are top 3 values of total invoice? */
select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
 
 select sum(total) as invoice_total, billing_city
 from invoice 
 group by billing_city
 order by invoice_total desc;
 
 /* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select customer.customer_id, customer.first_name, customer.last_name, 
sum(invoice.total) as total 
from customer  join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name, customer.last_name 
order by total desc 
limit 1;

/* B Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email, first_name, last_name from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like 'rock'
)
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.artist_id, a.name, count(a.artist_id) as number_of_songs
from track 
join album o


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds
from track 
where milliseconds > (
select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc;


/* C Q1: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

With popular_genre As 
(
select count(il.quantity) as purchases, c.country, g.name , g.genre_id,
row_number() over(partition by c.country order by count(il.quantity ) desc) as RowNo
from invoice_line il 
join invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id = i.customer_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre
where RowNo <= 1 

/* Q2: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

With customer_with_country AS (
select c.customer_id, first_name, last_name, billing_country, 
sum(total) as total_spending, 
row_number() over(partition by billing_country order by sum(total) desc ) as Rowno
from invoice i 
join customer c on c.customer_id = i.customer_id 
group by 1,2,3,4
order by 4 asc, 5 desc)
select * from customer_with_country 
where Rowno <= 1;
