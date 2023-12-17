--1
select country.continent, floor(avg(city.population))
from CITY inner join COUNTRY
on CITY.countrycode = country.code
group by country.continent
--2
select round(count(b.email_id)::DECIMAL/count(a.email_id),2)
from emails as a LEFT JOIN texts as b
on a.email_id = b.email_id
and signup_action = 'Confirmed'
--3
select b.age_bucket,
  ROUND(SUM(CASE WHEN a.activity_type= 'send' THEN a.time_spent end)/sum(time_spent)*100,2) as send_perc,
  ROUND(SUM(CASE WHEN a.activity_type= 'open' THEN a.time_spent end)/sum(time_spent)*100,2) as open_perc

from activities as a inner join age_breakdown as b 
  on a.user_id = b.user_id
where activity_type IN ('send', 'open')
group by b.age_bucket
--4
SELECT cc.customer_id
FROM customer_contracts as cc inner join products as p  
on cc.product_id = p.product_id
group by cc.customer_id
having count(distinct p.product_category) = 3
