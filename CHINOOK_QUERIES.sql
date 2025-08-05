use  chinook ;
show tables ;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--                                                                            ** Objective analysis **

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.Checking for null values and duplicates 

-- *** *** -- 
-- album table
select * from album ORDER BY album_id;

-- null check 
SELECT *
FROM album
WHERE album_id IS NULL or  title IS NULL OR artist_id IS NULL;

-- duplicates check 

SELECT  title,artist_id, COUNT(*) AS count
FROM album
GROUP BY  title,artist_id
HAVING COUNT(*) > 1;



--  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- artist table
-- null check 

select * from artist;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(artist_id) AS non_null_artist_ids,
    COUNT(name) AS non_null_names
FROM artist;

SELECT 
SUM(case when artist_id is null or name is null  then 1 else 0 end ) as cnt 
FROM artist
;

-- duplicate check 

select 
name,
count(*) as dup_cnt
from artist
group by name
having count(*)>1;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- employee table
select * from employee;

-- duplicate check 
SELECT first_name, last_name, email, COUNT(*) as dup_count
FROM employee
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- null check for employee -- (only CEO has null) 
SELECT *
FROM employee
WHERE employee_id IS NULL
   OR last_name IS NULL
   OR first_name IS NULL
   OR title IS NULL
   OR reports_to IS NULL
   OR birthdate IS NULL
   OR hire_date IS NULL
   OR address IS NULL
   OR city IS NULL
   OR state IS NULL
   OR country IS NULL
   OR postal_code IS NULL
   OR phone IS NULL
   OR fax IS NULL
   OR email IS NULL; 

-- UPDATE employee
-- set reports_to="NONE" where employee_id=1;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- genre table 
select * from genre;
-- null check for
select * from genre where genre_id is null or name is null ;

-- duplicate check
SELECT name, count(*) as duplicate_count
FROM genre
GROUP BY  name
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- invoice table
select * from invoice;

-- null check 

SELECT *
FROM invoice
WHERE invoice_id IS NULL
   OR customer_id IS NULL
   OR invoice_date IS NULL
   OR billing_address IS NULL
   OR billing_city IS NULL
   OR billing_state IS NULL
   OR billing_country IS NULL
   OR billing_postal_code IS NULL
   OR total IS NULL;

-- duplicate check 

SELECT  invoice_date, billing_address, total, COUNT(*) as duplicate_count
FROM invoice
GROUP BY  invoice_date, billing_address, total
HAVING COUNT(*) > 1;  

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 


-- invoice line table
select * from invoice_line order by invoice_id;

-- null check 
select * from invoice_line
where 
invoice_id is null or track_id is null or unit_price is null or unit_price is null or quantity is null ;

-- duplicate check 
SELECT invoice_id, track_id, unit_price, quantity, COUNT(*) AS duplicate_count
FROM invoice_line
GROUP BY invoice_id, track_id, unit_price, quantity
HAVING COUNT(*) > 1;
-- there are duplicates but not deleting them because same customer could have ordered multiple items 
-- to prove it we can see that the quantity of all invoice id is 1 at max
-- signifies database design picks max of 1 as quantity at once and assigns a invoice line id  

-- PROOF(*)
-- SELECT invoice_id, COUNT(DISTINCT track_id) AS distinct_tracks
-- FROM invoice_line
-- GROUP BY invoice_id
-- HAVING COUNT(DISTINCT track_id) > 1
-- LIMIT 10;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

-- media type table
select * from media_type;

--  null check
select * from media_type 
where name is null ;

-- duplicate check
select name from 
media_type
group by name 
having count(*) > 1 ; 

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- playlist table
select * from playlist;

-- null check
select * from playlist where name is null ;

-- duplicate check 
select name ,count(*) as dup_cnt from 
playlist 
group by name 
having count(*) >1 ;

-- deleting duplicates : 
SET SQL_SAFE_UPDATES = 0;


DELETE p1
FROM playlist p1
JOIN playlist p2 ON p1.name = p2.name AND p1.playlist_id > p2.playlist_id;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- playlist_track table
select * from playlist_track;

-- null check 
select * from playlist_track where track_id is null ;

-- duplicate check (music and tv shows have been duplicated with track id's hence deleting those id's)

DELETE from playlist_track where playlist_id in (8,10);

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

-- track table
select * from track;


-- null check 
SELECT track_id,name,composer
FROM track
WHERE name IS NULL
   OR album_id IS NULL
   OR media_type_id IS NULL
   OR genre_id IS NULL
   OR composer IS NULL
   OR milliseconds IS NULL
   OR bytes IS NULL
   OR unit_price IS NULL;


-- duplicates check

select 
name,album_id,media_type_id,genre_id,composer,milliseconds,bytes,unit_price, count(*) 
from 
track 
group by name,album_id,media_type_id,genre_id,composer,milliseconds,bytes,unit_price
having count(*) > 1; -- different artists/albums can have same track name 


 
-- handling nulls in the track table 
-- composer names updated using artist name, 

UPDATE track t
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
SET t.composer = ar.name
WHERE t.composer IS NULL;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- customer table 
select * from customer ;
						  
-- null check 
SELECT *
FROM customer
WHERE company IS  NULL
  or state IS  NULL
  or postal_code IS  NULL
  or phone IS  NULL
  or fax IS  NULL;
  
-- duplciate check  

select 
first_name,last_name,email 
from 
customer
group by first_name,last_name,email
having count(*)>1;

-- null handling
 
-- company with value null can be individuals 
UPDATE customer
SET company = 'Not Available'
WHERE company IS NULL;

-- phone value is null for one record where country is Hungary ,handled as below 
UPDATE customer
SET phone = '+36 XXXX-XXXX'  -- Hungarian country code + placeholder
WHERE country = 'Hungary' AND phone IS NULL;

-- fax with null as value 
UPDATE customer SET fax = 'Not Available' WHERE fax IS NULL;

-- postal codes with null as values 
-- strategy: based on the country and city name picked up values from web (verified) based on non null data values

-- Update Portuguese postal codes
UPDATE customer
SET postal_code = '1100-012'
WHERE customer_id = 34; -- Lisbon (Rua da Assunção 53)

UPDATE customer
SET postal_code = '4200-450'
WHERE customer_id = 35; -- Porto (Rua dos Campeões Europeus de Viena)

-- Update Irish postal code (Eircode format)
UPDATE customer
SET postal_code = 'D02 KX84'
WHERE customer_id = 46; -- Dublin (3 Chatham Street)

-- Update Chilean postal code
UPDATE customer
SET postal_code = '8320000'
WHERE customer_id = 57; -- Santiago (Calle Lira)


-- state with null values 
-- strategy : analysed the pattern of the non null values and handled it as below 
UPDATE customer
SET state = CASE
    -- Germany
    WHEN city = 'Stuttgart' THEN 'BW'   -- Baden-Württemberg
    WHEN city = 'Berlin' THEN 'BE'      -- Berlin (city-state)
    WHEN city = 'Frankfurt' THEN 'HE'   -- Hesse
    
    -- France (department codes)
    WHEN city = 'Paris' THEN '75'       -- Paris department
    WHEN city = 'Lyon' THEN '69'        -- Rhône department
    WHEN city = 'Bordeaux' THEN '33'    -- Gironde department
    WHEN city = 'Dijon' THEN '21'       -- Côte-d'Or department
    
    -- Other European cities
    WHEN city = 'Prague' THEN 'PRG'     -- Prague (capital)
    WHEN city = 'Brussels' THEN 'BRU'   -- Brussels-Capital Region
    WHEN city = 'Vienna' THEN 'W'       -- Vienna (Wien)
    WHEN city = 'Budapest' THEN 'BU'    -- Budapest (capital)
    WHEN city = 'Warsaw' THEN 'MZ'      -- Masovian Voivodeship
    WHEN city = 'Madrid' THEN 'M'       -- Madrid autonomous community
    WHEN city = 'Lisbon' THEN 'LIS'     -- Lisbon district
    WHEN city = 'Porto' THEN 'POR'      -- Porto district
    WHEN city = 'Stockholm' THEN 'AB'   -- Stockholm County
    
    -- Unitary countries (country codes)
    WHEN city = 'London' THEN 'GB'      -- United Kingdom
    WHEN city = 'Edinburgh' THEN 'GB'   -- United Kingdom
    WHEN city = 'Oslo' THEN 'NO'        -- Norway
    WHEN city = 'Copenhagen' THEN 'DK'  -- Denmark
    WHEN city = 'Helsinki' THEN 'FI'    -- Finland
    
    -- Rest of world
    WHEN city = 'Buenos Aires' THEN 'BA'  -- Buenos Aires
    WHEN city = 'Santiago' THEN 'RM'      -- Santiago Metropolitan Region
    WHEN city = 'Delhi' THEN 'DL'         -- Delhi NCT
    WHEN city = 'Bangalore' THEN 'KA'     -- Karnataka
    
    -- Default: First 2 letters of city (UPPERCASE)
    ELSE UPPER(SUBSTRING(city, 1, 2))
END
WHERE state IS NULL;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from album;
select * from artist;
select * from  customer;
select * from employee;
select * from  genre;
select * from  invoice;
select * from  invoice_line;
select * from  media_type;
select * from  playlist;
select * from  playlist_track;
select * from track;

-- Clean data considered for analysis of further detailed questions 
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2.Top-selling tracks and top artist in the USA and their most famous genres :

-- top 5 tracks in USA :
SELECT 
    t.track_id,
    t.name,
    SUM(il.quantity) AS total_quantity,
    SUM(il.quantity * il.unit_price) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
WHERE i.billing_country = 'USA'
GROUP BY t.track_id, t.name
ORDER BY total_revenue DESC, total_quantity DESC
LIMIT 5;

-- top artist in USA 
SELECT 
    a.artist_id,
    a.name AS artist_name,
    SUM(il.quantity) AS total_quantity,
    SUM(il.quantity * il.unit_price) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album alb ON t.album_id = alb.album_id
JOIN artist a ON alb.artist_id = a.artist_id
WHERE i.billing_country = 'USA'
GROUP BY a.artist_id, a.name
ORDER BY total_revenue DESC, total_quantity DESC
LIMIT 1;

-- top genre of the top artist 
SELECT 
    g.genre_id,
    g.name AS genre_name,
    SUM(il.quantity) AS total_quantity,
    SUM(il.quantity * il.unit_price) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album alb ON t.album_id = alb.album_id
JOIN artist a ON alb.artist_id = a.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
AND a.artist_id = 152 -- top artist in USA as per previous query
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC, total_quantity DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Customer demographic breakdown (age, gender, location) of Chinook's customer base
--  no data related to gender , age ( no columns to compute these as well )

-- Top countries 
SELECT 
    country,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 1) AS percentage
FROM customer
GROUP BY country
ORDER BY customer_count DESC
limit 5;

-- Top cities globally (regardless of country/state)
SELECT 
    city,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 1) AS percentage
FROM customer
WHERE city IS NOT NULL AND city != ''
GROUP BY city
ORDER BY customer_count DESC
LIMIT 5;  

-- Top states  globally (regardless of country/city)
SELECT 
    state,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 1) AS percentage
FROM customer
WHERE state IS NOT NULL AND city != ''
GROUP BY state
ORDER BY customer_count DESC
LIMIT 5;  


-- combined demographic analysis : 
-- Granular view (city within state within country)
SELECT 
    country,
    state,
    city,
    COUNT(*) AS customer_count
FROM customer
WHERE 
    city IS NOT NULL AND city != '' AND
    state IS NOT NULL AND state != '' AND
    country IS NOT NULL AND country != ''
GROUP BY country, state, city
order by customer_count DESC,country
limit 5 ;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Total revenue and number of invoices for each country, state, and city:

-- country based total revenue and invoice count 
SELECT 
    c.country,
    COUNT(i.invoice_id) AS total_invoices,
    SUM(i.total) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
WHERE c.country IS NOT NULL AND c.country != ''
GROUP BY c.country
ORDER BY total_revenue DESC;

-- state based total revenue and invoice count
SELECT 
    c.state,
    COUNT(i.invoice_id) AS total_invoices,
    SUM(i.total) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
WHERE c.state IS NOT NULL AND c.state != ''
GROUP BY c.state
ORDER BY total_revenue DESC;

-- city based total revenue and invoice count

SELECT 
    c.city,
    COUNT(i.invoice_id) AS total_invoices,
    SUM(i.total) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
WHERE c.city IS NOT NULL AND c.city != ''
GROUP BY  c.city
ORDER BY total_revenue DESC
LIMIT 10; 


-- granular ( country , state , city ) :
SELECT 
    c.country,
    c.state,
    c.city,
    COUNT(i.invoice_id) AS total_invoices,
    SUM(i.total) AS total_revenue,
    ROUND(SUM(i.total) / COUNT(i.invoice_id), 2) AS avg_order_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
WHERE 
    c.country IS NOT NULL AND c.country != '' AND
    c.state IS NOT NULL AND c.state != '' AND
    c.city IS NOT NULL AND c.city != ''
GROUP BY c.country, c.state, c.city
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Top 5 customers by total revenue in each country

WITH customer_revenue AS (
    SELECT 
        c.country,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(i.total) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY c.country 
            ORDER BY SUM(i.total) DESC
        ) AS revenue_rank,
        COUNT(*) OVER (PARTITION BY c.country) AS customers_in_country
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    WHERE c.country IS NOT NULL AND c.country != ''
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_name,
    country,
    total_revenue,
    revenue_rank,
    customers_in_country
FROM customer_revenue
WHERE revenue_rank <= 5
ORDER BY 
    customers_in_country ASC,  -- Countries with most customers i.e 5 at the end 
    country,
    revenue_rank;
    
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.The top-selling track for each customer:

WITH customer_track_purchases AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        t.track_id,
        t.name AS track_name,
        COUNT(*) AS times_purchased,
        SUM(il.unit_price * il.quantity) AS total_spent,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id order by  SUM(il.unit_price * il.quantity) DESC ,  COUNT(*) DESC
        ) AS track_rank
    FROM customer c
    JOIN invoice inv ON c.customer_id = inv.customer_id
    JOIN invoice_line il ON inv.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id, c.first_name, c.last_name, t.track_id, t.name
)
SELECT 
    customer_id,
    customer_name,
    track_name,
    times_purchased,
    total_spent
FROM customer_track_purchases
WHERE track_rank = 1
ORDER BY customer_id;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7. Are there any patterns or trends in customer purchasing behavior 
-- (e.g., frequency of purchases, preferred payment methods, average order value)
-- payment_method data is not available 


-- purchase frequency per customer : 
SELECT 
    c.customer_id,
    CONCAT(c.first_name," ",c.last_name) as customer_name,
    COUNT(i.invoice_id) AS total_purchases,
    MIN(i.invoice_date) AS first_purchase,
    MAX(i.invoice_date) AS last_purchase,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS span_days
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,customer_name
ORDER BY  total_purchases desc,span_days asc;

-- average order value, lifetime_value  per customer 
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(AVG(i.total), 2) AS avg_order_value,
    ROUND(SUM(i.total), 2) AS lifetime_value,
    COUNT(*) AS total_orders
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY avg_order_value DESC;


-- customers year wise purchase frequency with total order value and avg order value 
SELECT  c.customer_id, concat(c.first_name,' ', c.last_name) as customer_name,
	year(i.invoice_date) as year,count(i.invoice_id) as purchase_count,
	sum(i.total) as tot_revenue, avg(i.total) as avg_ord_value
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, customer_name, year(i.invoice_date)
order by c.customer_id, customer_name, year(i.invoice_date);

-- additional analysis : country wise order value distribution (avg, total , no's) 

SELECT 
    billing_country,
    ROUND(AVG(total), 2) AS avg_order_value,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(*) AS num_orders
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8. Customer churn rate:

with cte as (
select max(invoice_date) as recent_inovice_date from invoice
),last_year as (
select date_sub(recent_inovice_date,INTERVAL 1 YEAR) as last_year_dt from cte
),churn_customers as 
( 
select c.customer_id 
from customer c join invoice i on c.customer_id=i.customer_id 
group by customer_id
having max(invoice_date)<(select last_year_dt from last_year)
)

select (select count(*) from churn_customers)/(select count(*) from customer) * 100 as churn_rate;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9 . The percentage of total sales contributed by each genre in the USA and the best-selling genres and artists


select distinct g.name,
		sum(il.quantity) over(partition by g.name)  as genre_tot_sales,
		( sum(il.quantity) over(partition by g.name)  *100/sum(il.quantity) over() ) as genre_perc
from invoice i
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
where i.billing_country='USA'
order by genre_tot_sales desc;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10. Customers who have purchased tracks from at least 3 different genres

select concat(c.first_name,' ',c.last_name) as customer_name,
		 count(distinct g.genre_id) as genres_purchased
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
group by customer_name
having count(distinct g.genre_id)>=3
order by genres_purchased desc;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 11. Rank genres based on their sales performance in the USA

select g.name,	
		sum(il.quantity*il.unit_price) as total_revenue,
        dense_rank() over ( order by sum(il.quantity) desc) as rnk
from invoice i
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id 
where i.billing_country='USA'
group by g.name
order by rnk;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 12.Customers who have not made a purchase in the last 3 months

with latest_billday as(
select date_add( max(date(invoice_date)),interval -3 month) as recent_day
from invoice)

select distinct c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name
from customer c
join invoice i on c.customer_id=i.customer_id
group by customer_id
having max(i.invoice_date)<(select * from latest_billday)
order by c.customer_id;
    
    

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--                                                                                          ** subjective analysis ** 


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1.Recommend the three albums from the new record label that should be prioritised for advertising 
-- and promotion in the USA based on genre sales analysis

with cte as(
select g.name as genre_name, al.title as album_title, 
			sum(il.unit_price * il.quantity) as album_sales,
			dense_rank() over (partition by g.name order by sum(il.unit_price*il.quantity) desc) rnk
 from genre g 
join track t on g.genre_id = t.genre_id
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
join album al on t.album_id = al.album_id
where i.billing_country = 'USA'
group by  g.name, al.title
having sum(il.quantity) >4 )  -- considering only albums with more than 4 units sold

select *
from cte
where rnk<=3 -- selecting top 3 albums per genre 
order by album_sales desc;

-- -----------------------------------------------------------------------------------------------------------------------

-- 2. Determining the top-selling genres in countries other than the USA and identifying any commonalities or differences

with genresales as (
    select i.billing_country,g.name as genre_name,sum(il.quantity * t.unit_price) as total_sales,
        row_number() over(partition by i.billing_country order by sum(il.quantity * t.unit_price) desc)
        as rnk from invoice_line il
    join track t
    on il.track_id = t.track_id
    join genre g 
    on t.genre_id = g.genre_id
    join invoice i 
    on il.invoice_id = i.invoice_id
    where i.billing_country != 'usa'
    group by i.billing_country, g.name
)
select billing_country,genre_name,total_sales from genresales 
where rnk <= 3;

-- ------------------------------------------------------------------------------------------------------------------------
-- 3.Customer Purchasing Behavior Analysis: 
-- How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers? 
-- What insights can these patterns provide about customer loyalty and retention strategies?



-- Analysis based on the total number of days the customer has stayed active with purchases , as long term customers 
with customer_details as (
select c.customer_id, count(distinct i.invoice_id) as tot_purchases, sum(il.quantity) as basket_size, 
			sum(i.total) as total_spent, round(avg(i.total),2) as avg_order_value,
			(
            case
            when datediff(max(i.invoice_date), min(i.invoice_date)) >=1050 then 'long-term customers' 
            else 'new customers' 
            end 
            )as customer_category 
from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
group by c.customer_id
)

select 
customer_category, 
round(avg(tot_purchases),2) as avg_purchase_frequency,
round(avg(basket_size),2) as avg_basket_size, 
round(avg(total_spent),2) as avg_spending_amount,
round(avg(avg_order_value),2) as avg_order_value
from customer_details
group by customer_category

-- could also be analysed based on the year and month  

-- --------------------------------------average and total amount spent by each old customer------------------------------------------------------------------

 select 
 c.customer_id, 
 concat(c.first_name,' ',c.last_name) as old_cust_name,
 sum(i.total) as total_amount, 
 round(avg(i.total),2) as avg_amount 
 from customer c 
 join invoice i 
 on c.customer_id = i.customer_id 
 where c.customer_id not in 
 (select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
 group by c.customer_id, old_cust_name
 order by c.customer_id;
 -- --------------------------------------------average and total amount spent by new customers---------------------------------------------------------

select c.customer_id, concat(c.first_name,' ',c.last_name) as new_cust_name, 
sum(i.total) as total_amount, round(avg(i.total),2) as avg_amount from customer c 
join invoice i 
on c.customer_id = i.customer_id 
where c.customer_id  in
 (select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
group by c.customer_id, new_cust_name
order by c.customer_id;


-- --------------------------------------------------total items purchased  by old_customers---------------------------------------------------------------------
select c.customer_id, concat(c.first_name,' ',c.last_name) as old_cust_name, 
sum(il.quantity) as purchased_items from customer c
join invoice i 
on c.customer_id = i.customer_id 
join invoice_line il 
on i.invoice_id = il.invoice_id 
where c.customer_id not in 
(select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
group by c.customer_id,old_cust_name
order by c.customer_id ;

-- ------------------------------------------------total items purchased  by new customers-------------------------------------------------------------------------

select c.customer_id, concat(c.first_name,' ',c.last_name) as new_cust_name, 
sum(il.quantity) as purchased_items from customer c
join invoice i 
on c.customer_id = i.customer_id 
join invoice_line il 
on i.invoice_id = il.invoice_id 
where c.customer_id  in
 (select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
group by c.customer_id,new_cust_name
order by c.customer_id ;

-- ----------------------------------------------top tracks of old customers -----------------------------------------------------------------------------------
with top_tracks as (
select distinct c.customer_id, t.track_id,t.name,
sum(il.quantity*il.unit_price) over(partition by t.track_id ) as total_price 
from customer c join invoice i 
on c.customer_id = i.customer_id
join invoice_line il 
on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
where c.customer_id not in 
(select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
 ),track_rank as (
select customer_id,track_id,name,
row_number() over(partition by customer_id order by total_price desc) as rn from top_tracks)

select customer_id, track_id,name as track_name from track_rank
where rn = 1;

--  -----------------------------------------------top tracks of new_customers -----------------------------------------------------------------------------------

with top_tracks as (
select distinct c.customer_id, t.track_id,t.name,
sum(il.quantity*il.unit_price) over(partition by t.track_id ) as total_price from customer c 
join invoice i 
on c.customer_id = i.customer_id
join invoice_line il 
on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
where c.customer_id  in 
(select customer_id from invoice where invoice_date between '2020-09-30' and '2020-12-31') 
 ),
track_rank as (
select
customer_id,track_id,name,
row_number() over(partition by customer_id order by total_price desc) as rn from top_tracks)
select customer_id, track_id,name as track_name from track_rank
where rn = 1;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4.Product Affinity Analysis: 
-- Which music genres, artists, or albums are frequently purchased together by customers 
-- How can this information guide product recommendations and cross-selling initiatives

-- Genre Affinity Analysis:

select 
distinct g1.name as genre01, 
g2.name as genre02,
count(distinct il1.invoice_id) as quantity_bought
from invoice_line il1
join invoice_line il2 on il1.invoice_id = il2.invoice_id and il1.track_id < il2.track_id
join track t1 on il1.track_id = t1.track_id
join track t2 on il2.track_id = t2.track_id
join genre g1 on t1.genre_id = g1.genre_id
join genre g2 on t2.genre_id = g2.genre_id where g1.genre_id < g2.genre_id
group by genre01,genre02
order by quantity_bought desc ;

-- Artist Affinity Analysis:

SELECT 
ar1.name AS artist01, 
ar2.name AS artist02, 
COUNT(DISTINCT il1.invoice_id) AS quantity_bought
FROM invoice_line il1
JOIN invoice_line il2 
ON il1.invoice_id = il2.invoice_id 
AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album a1 ON t1.album_id = a1.album_id
JOIN album a2 ON t2.album_id = a2.album_id 
JOIN artist ar1 ON a1.artist_id = ar1.artist_id
JOIN artist ar2 ON a2.artist_id = ar2.artist_id
WHERE ar1.artist_id < ar2.artist_id  
GROUP BY artist01, artist02
ORDER BY quantity_bought DESC ;

-- Album Affinity Analysis:

select 
distinct a1.title as album01, 
a2.title as album02, 
count( distinct il1.invoice_id ) as quantity_bought
from invoice_line il1
join invoice_line il2 on il1.invoice_id = il2.invoice_id and il1.track_id < il2.track_id
join track t1 on il1.track_id = t1.track_id
join track t2 on il2.track_id = t2.track_id
join album a1 on t1.album_id = a1.album_id
join album a2 on t2.album_id = a2.album_id where a1.album_id < a2.album_id
group by album01,album02
order by quantity_bought desc ;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Regional Market Analysis: 
-- Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations? 
-- How might these correlate with local demographic or economic factors

-- ------------------------------------------------- total sales , quantity bought  by region -----------------------------------
select 
c.country,
count(i.invoice_id) as quantity_bought,
sum(il.quantity*il.unit_price) as total_sales from customer c
join invoice i 
on c.customer_id = i.customer_id
join invoice_line il 
on il.invoice_id = i.invoice_id
group by c.country
order by quantity_bought desc,total_sales desc;

-- ----------------------------------------------- churn rate by region -----------------------------------------------------------
WITH 
last_year_date AS (
    SELECT DATE_SUB(MAX(invoice_date), INTERVAL 1 YEAR) AS cutoff_date 
    FROM invoice
),
customer_status AS (
    SELECT 
        c.customer_id,
        c.country,
        MAX(i.invoice_date) AS last_purchase_date,
        CASE 
            WHEN MAX(i.invoice_date) < (SELECT cutoff_date FROM last_year_date) 
                 OR MIN(i.invoice_date) IS NULL THEN 1
            ELSE 0
        END AS is_churned
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
)

SELECT 
    country,
    COUNT(*) AS total_customers,
    SUM(is_churned) AS churned_customers,
    ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customer_status
GROUP BY country
ORDER BY churn_rate_pct DESC;

-- 1/59 (1.69 churn rate verified )
-- ----------------------------------------------------------------------------------------------------------

-- 6.Customer Risk Profiling: 
-- Based on customer profiles (age, gender, location, purchase history), 
-- which customer segments are more likely to churn or pose a higher risk of reduced spending? 
-- What factors contribute to this risk

-- NOTE : age & gender data is not available 

WITH latest_invoice AS (
    SELECT DATE_SUB(MAX(invoice_date), INTERVAL 1 YEAR) AS cutoff_date 
    FROM invoice
),
customer_rfm AS (
    SELECT 
        c.customer_id,
        c.country,
        MAX(i.invoice_date) AS last_purchase_date,
        COUNT(i.invoice_id) AS total_orders,
        ROUND(SUM(i.total), 2) AS total_spent,
        CASE 
            WHEN MAX(i.invoice_date) < (SELECT cutoff_date FROM latest_invoice) THEN 1
            ELSE 0
        END AS is_churned
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT 
    country,
    COUNT(*) AS total_customers,
    SUM(is_churned) AS churned_customers,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    ROUND(AVG(total_spent), 2) AS avg_spent,
    ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customer_rfm
GROUP BY country
ORDER BY churn_rate_pct DESC, avg_spent ASC,avg_orders asc; -- high churn rate , lesser spending trend , lesser no of avg orders 


-- OR 

 with customer_profile as (
	select
		c.customer_id,
        concat(c.first_name,' ',c.last_name) as customer_name,
        c.country,
        coalesce(c.state,"Not Available") as state,
        c.city,
        max(i.invoice_date) as last_purchase_date,
        count(i.invoice_id) as purchase_frequency,
        sum(i.total) as total_spending,
        avg(i.total) as avg_order_value,
        case 
			when max(i.invoice_date) < date_sub((select max(invoice_date) from invoice), interval 1 year) then 'High Risk' 
			when sum(i.total) < 100 then 'Medium Risk' 
            else 'Low Risk'
		end as risk_profile
    from customer c 
    join invoice i on c.customer_id = i.customer_id
    group by c.customer_id, customer_name, c.country, state, c.city
),
risk_summary as (
	select
		country, state, city, risk_profile,
        count(customer_id) as num_customer,
        round(avg(total_spending), 2) as avg_total_spending,
        round(avg(purchase_frequency), 2) as avg_purchase_frequency,
        round(avg(avg_order_value), 2) as avg_order_value
	from customer_profile
    group by country, state, city, risk_profile
)
select * 
from risk_summary
order by 
	case 
		when risk_profile = 'High Risk' then 1
		when risk_profile = 'Medium Risk' then 2
		when risk_profile = 'Low Risk' then 3
	end,
    avg_total_spending asc;


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Customer Lifetime Value Modeling: 
-- How can you leverage customer data (tenure, purchase history, engagement) to predict the lifetime value of different customer segments? 
-- This could inform targeted marketing and loyalty program strategies. 
-- Can you observe any common characteristics or purchase patterns among customers who have stopped purchasing?



        
-- Customer Lifestyle Analysis
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COALESCE(c.state, 'Not Available') AS state,
    c.city,
    MIN(i.invoice_date) AS first_purchase_date,
    MAX(i.invoice_date) AS last_purchase_date,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS customer_tenure_days,
    COUNT(i.invoice_id) AS total_purchase,
    SUM(i.total) AS total_spending,
    AVG(i.total) AS avg_order_value,
    CASE 
        WHEN MAX(i.invoice_date) < (SELECT MAX(invoice_date) FROM invoice) - INTERVAL 1 YEAR THEN 'Churn'
        ELSE 'Active' 
    END AS status,
    CASE
        WHEN DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) >= 1050 THEN 'Long term'
        ELSE 'Short term'
    END AS customer_segment,
    SUM(i.total) / GREATEST(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)), 1) * 365 AS predicted_annual_value,
    SUM(i.total) AS lifetime_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name, c.country, state, c.city;

-- Segment Analysis
WITH customer_lifeStyle_analysis AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        COALESCE(c.state, 'Not Available') AS state,
        c.city,
        MIN(i.invoice_date) AS first_purchase_date,
        MAX(i.invoice_date) AS last_purchase_date,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS customer_tenure_days,
        COUNT(i.invoice_id) AS total_purchase,
        SUM(i.total) AS total_spending,
        AVG(i.total) AS avg_order_value,
        CASE 
           WHEN MAX(i.invoice_date) < (SELECT MAX(invoice_date) FROM invoice) - INTERVAL 1 YEAR THEN 'Churn'
            ELSE 'Active' 
        END AS customer_status,
        CASE
            WHEN DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) >= 1050 THEN 'Long term'
            ELSE 'Short term'
        END AS customer_segment,
        SUM(i.total) / GREATEST(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)), 1) * 365 AS predicted_annual_value -- predicting value for year based on value_per_day
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customer_name, c.country, state, c.city
)
SELECT
    customer_segment,
    customer_status,
    COUNT(customer_id) AS num_customer,
    AVG(customer_tenure_days) AS avg_tenure_days,
    AVG(total_spending) AS avg_lifetime_value,
    AVG(predicted_annual_value) AS avg_predicted_annual_value
FROM customer_lifeStyle_analysis 
GROUP BY customer_segment, customer_status;

-- Churn Analysis
WITH customer_lifeStyle_analysis AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        COALESCE(c.state, 'Not Available') AS state,
        c.city,
        MAX(i.invoice_date) AS last_purchase_date,
        SUM(i.total) AS total_spending,
        CASE 
            WHEN MAX(i.invoice_date) < (SELECT MAX(invoice_date) FROM invoice) - INTERVAL 1 YEAR THEN 'Churn'
            ELSE 'Active' 
        END AS status,
        CASE
            WHEN DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) >= 1050 THEN 'Long term'
            ELSE 'Short term'
        END AS customer_segment
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customer_name, c.country, state, c.city
)
SELECT
    country,
    state,
    city,
    customer_segment,
    COUNT(customer_id) AS churned_customer,
    AVG(total_spending) AS avg_lifetime_value
FROM customer_lifeStyle_analysis
WHERE status = 'Churn'
GROUP BY country, state, city, customer_segment;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8.If data on promotional campaigns (discounts, events, email marketing) is available,
-- how could you measure their impact on customer acquisition, retention, and overall sales?

-- *Answer in doc*

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9.How would you approach this problem, if the objective and subjective questions weren't given?

-- *Answer in DOC*

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10. How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?

alter table album
add column releaseyear integer;


select * from album;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 11.Chinook is interested in understanding the purchasing behavior of customers based on their geographical location. 
-- Average total amount spent by customers from each country,number of customers , average number of tracks purchased per customer. 


with tracks_per_customer as (	
    select 
        i.customer_id,
        sum(il.quantity) as total_tracks
    from invoice i
    join invoice_line il on i.invoice_id = il.invoice_id
    group by i.customer_id
),
customer_spending as (
    select 
        c.country,
        c.customer_id,
        sum(i.total) as total_spent,
        tpc.total_tracks
    from customer c
    join invoice i on c.customer_id = i.customer_id
    join tracks_per_customer tpc on c.customer_id = tpc.customer_id
    group by c.country, c.customer_id, tpc.total_tracks
)
select 
    cs.country,
    count(distinct cs.customer_id) as number_of_customers,
    round(avg(cs.total_spent), 2) as average_amount_spent_per_customer,
    round(avg(cs.total_tracks), 2) as average_tracks_purchased_per_customer
from customer_spending cs
group by cs.country
order by average_amount_spent_per_customer desc;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--                                                                                                   *END*


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
