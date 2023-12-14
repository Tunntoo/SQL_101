--1 
select name
from STUDENTS
where Marks > 75
order by right(name,3), ID
--2
select user_id,
CONCAT(UPPER(LEFT(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) as name
from Users
order by user_id
--3
SELECT manufacturer,
CONCAT('$',ROUND(SUM(total_sales)/1000000, 0), ' million') AS sale_mil
FROM pharmacy_sales
GROUP by manufacturer
ORDER BY SUM(total_sales) DESC
--4
SELECT 
EXTRACT(MONTH from submit_date) AS mth,
product_id,
ROUND(avg(stars),2) AS avg_stars
FROM reviews
GROUP BY EXTRACT(MONTH from submit_date), product_id
ORDER BY EXTRACT(MONTH from submit_date), product_id
--5
SELECT sender_id,
COUNT(sender_id) as count_messages
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-09-01'
GROUP BY sender_id
ORDER BY COUNT(content) DESC
LIMIT 2
--6
SELECT tweet_id 
FROM Tweets
WHERE LENGTH(content) > 15
--7
SELECT
activity_date AS day,
COUNT(DISTINCT(user_id)) AS active_users
FROM Activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-28'
GROUP BY activity_date
--8
SELECT
COUNT(id)
FROM employees
WHERE joining_date BETWEEN '2022-01-01' AND '2022-07-01'
--9
select 
POSITION ('a' IN first_name)
from worker
where first_name = 'Amitah'
--10
select 
title,
SUBSTRING (title FROM (LENGTH(winery)+2) FOR 4) AS year
from winemag_p2
where country = 'Macedonia'
