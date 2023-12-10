---1
SELECT DISTINCT CITY FROM STATION
WHERE ID%2 = 0
--2
SELECT 
COUNT(CITY) - COUNT(DISTINCT CITY)
FROM STATION
--3
SELECT 
ROUND(AVG(SALARY)) - ROUND(AVG(REPLACE(SALARY, 0, '')))
FROM EMPLOYEES
--4
SELECT 
 ROUND(
 SUM(item_count::DECIMAL*order_occurrences) / SUM(order_occurrences),1) AS mean
FROM items_per_order
--5
SELECT candidate_id FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(candidate_id)>=3
ORDER BY candidate_id 
--6
SELECT 
  user_id,
  DATE(MAX(post_date))-DATE(MIN(post_date)) AS day_between
FROM posts
WHERE post_date >= '2021-01-01' AND post_date <'2022-01-01'
GROUP BY user_id
HAVING COUNT(user_id)>1 
--7
SELECT 
  card_name,
  MAX(issued_amount) - MIN(issued_amount)
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY MAX(issued_amount) - MIN(issued_amount) DESC
--8
SELECT 
  manufacturer,
  COUNT (drug) AS drug_count,
  SUM(cogs-total_sales) AS total_loss
FROM pharmacy_sales
WHERE cogs - total_sales >0
GROUP BY manufacturer
ORDER BY  SUM(cogs-total_sales) DESC
--9
Select * from Cinema
where id%2 != 0
and description != "boring"
order by rating desc
--10
SELECT 
teacher_id, 
COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id
--11
SELECT user_id, 
COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
--12
SELECT class FROM Courses
HAVING COUNT(class) >=5
