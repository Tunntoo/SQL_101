--1
SELECT
extract (year from transaction_date) as year, 
product_id,
spend as curr_year_spend, 
LAG(spend) OVER(PARTITION BY product_id ORDER BY transaction_date) as prev_year_spend,
ROUND(100*((spend - (LAG(spend) OVER(PARTITION BY product_id ORDER BY transaction_date)))
/LAG(spend) OVER(PARTITION BY product_id ORDER BY transaction_date)), 2) as yoy_rate
FROM user_transactions

--2
SELECT 
DISTINCT card_name, 
FIRST_VALUE (issued_amount) OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) as issued_amount
FROM monthly_cards_issued
ORDER BY issued_amount DESC

--3
with cte as (
SELECT 
user_id, 
spend,
transaction_date,
ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) as stt
FROM transactions)

SELECT user_id, spend, transaction_date
FROM cte 
WHERE stt = 3

--4
with cte as (SELECT 
transaction_date, user_id, 
count(*) over(partition by user_id, transaction_date order by transaction_date desc) as purchase_count
from user_transactions),

ranking as (select 
transaction_date, user_id, purchase_count,
row_number() over(partition by user_id order by transaction_date desc) as ranking
from cte )

select transaction_date, user_id, purchase_count
from ranking
where ranking = 1
order by transaction_date 

--5
select user_id,
tweet_date,
round(avg(tweet_count) over(partition by user_id order by tweet_date rows between 2 preceding and current row), 2) as rolling_avg_3d
from tweets

--6
with cte as (SELECT 
merchant_id, credit_card_id, amount, transaction_timestamp, 
lag (transaction_timestamp) over (partition by merchant_id, credit_card_id, amount order by transaction_timestamp) as previous_transaction,
EXTRACT(minute from transaction_timestamp - (lag (transaction_timestamp) over (partition by merchant_id, credit_card_id, amount order by transaction_timestamp)))as difference
from transactions)

select count(difference) as payment_count
from cte 
where difference < 10

--7
with cte as (select category, product, 
sum(spend) as total_spend,
rank() over(partition by category order by sum(spend) DESC) as ranking
from product_spend
where extract (year from transaction_date) = 2022
group by category, product)

select category, product, total_spend
from cte 
where ranking = 1 or ranking = 2
order by category, total_spend DESC

--8
with cte as (select c.artist_name,
dense_rank() over(order by count(*) DESC) as ranking
from global_song_rank as a
join songs as b on a.song_id = b.song_id
join artists as c on b.artist_id = c.artist_id
where rank <= 10
group by c.artist_name) 

select 
artist_name,
ranking
from cte
where ranking <=5
