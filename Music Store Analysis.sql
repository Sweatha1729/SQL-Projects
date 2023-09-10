                                          -- MUSIC STORE ANALYSIS PROJECT --
use chinook;
show tables;
select * from album;

-- Question 1: Which country has the most invoices?

select * from invoice;
select count(*),billingcountry 
from invoice 
group by 2 order by 1 desc;
-- USA has the most invoices

-- Question 2: What are the top 3 values of total invoice?

select * from invoice 
order by total desc 
limit 3;

-- Question 3: Write a query to find which city has the best customers and sum of all invoice totals.

select * from invoice;
select sum(total) as total_invoice,billingcity
from invoice
group by billingcity order by total_invoice desc;
-- Prague has the highest sum of invoice sales

-- Question 4: Write a query that returns the top 5 customers who has spent the most money.

select c.customerid,c.firstname,c.lastname,sum(i.total) as total_invoice from 
customer c join invoice i
using(customerid) group by 1 order by total_invoice desc limit 5;

/* Question 5: Write a query to return the email,firstname,lastname and genre of all rock music listeners.
Return your list ordered alphabetically by email */

SELECT DISTINCT
    c.email, c.firstname, c.lastname
FROM
    customer c
        JOIN
    invoice i USING (customerid)
        JOIN
    invoiceline USING (invoiceid)
WHERE
    trackid IN (SELECT 
            t.trackid
        FROM
            track t
                JOIN
            genre g USING (genreid)
        WHERE
            g.name LIKE 'Rock')
ORDER BY email ASC;

-- Question 6: Write a query that returns the artist name and total track count of the top 10 rock bands.

select ar.artistid,ar.name,count(ar.artistid) as no_of_songs
from track t 
join album a using(albumid)
join artist ar using(artistid)
join genre g on g.genreid=t.genreid
where g.name='Rock' 
group by 1 
order by no_of_songs desc 
limit 10;

/* Question 7: Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each 
track. Order by the song length with the longest songs listed first */

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;

-- Question 8: Find how much amount spent by each customer on artists? Write a query that returns customer name,artist name and total spent.

with best_selling_artist as
(
select ar.artistid,ar.name,sum(il.unitprice*il.quantity) as total_sales
from invoiceline il
join track t on t.trackid=il.trackid
join album a on t.albumid=a.albumid
join artist ar on ar.artistid=a.artistid
group by 1
order by 3 desc
limit 1
)
select c.customerid,c.firstname,c.lastname,bsa.name,sum(ilv.unitprice*ilv.quantity) as amount_spent
from invoice iv
join customer c on c.customerid=iv.customerid
join invoiceline ilv on ilv.invoiceid=iv.invoiceid
join track tr on tr.trackid=ilv.trackid
join album al on al.albumid=tr.albumid
join best_selling_artist bsa on bsa.artistid=al.artistid
group by 1,2,3,4
order by amount_spent desc;

/* Question 9: Write a query that returns the each country along with the top genre. For countries where the maximum no of purchases is shared
return all Genres */

with popular_genre as
(
select count(il.quantity) as purchases,c.country,g.Name,g.genreid,
row_number() over(partition by c.country order by count(il.quantity) desc) as RowNo
from invoiceline il 
join invoice i using(invoiceid)
join customer c using(customerid)
join track t on t.trackid=il.trackid
join genre g on g.genreid=t.genreid
group by 2,3,4
order by 1 desc
)
select * from popular_genre where RowNo <= 1;

/*Question 10: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country 
along with the top customer and how much they spent.For countries where the top amount spend is shared,provide all customers who spent this amount*/

with customer_with_country as
(
select c.customerid,firstname,lastname,billingcountry,sum(total) as total_spent,
row_number() over(partition by billingcountry order by sum(total) desc) as RowNo
from invoice i
join customer c using(customerid)
group by 1,2,3,4
order by 4 asc,5 desc
)
select * from customer_with_country where RowNo <= 1;








