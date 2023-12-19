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
--5
select mng.employee_id, mng.name, 
    count(emp.reports_to) as reports_count, 
    round(avg(emp.age),0) as average_age
from Employees as emp left JOIN Employees as mng
on emp.reports_to = mng.employee_id
where mng.employee_id IS NOT NULL 
group by mng.employee_id, mng.name
--6
select b.product_name, sum(a.unit) as unit

from Orders as a left join Products as b
on a.product_id = b.product_id
where extract(month from a.order_date)= 2
group by b.product_name
having sum(a.unit)>=100
--7
SELECT p.page_id
FROM pages as p left join page_likes as l   
on p.page_id = l.page_id
WHERE liked_date IS NULL
order by p.page_id

-------------------MID-COURSE TEST ---------------------
--1
select distinct replacement_cost from film
order by replacement_cost
--2
select count(film_id),
CASE 
	when replacement_cost between 9.99 and 19.99 then 'low'
	when replacement_cost between 20.00 and 24.99 then 'medium'
	else 'high'
END as category
from film
group by category
--3
select f.title, f.length, ca.name 
from category as ca 
INNER JOIN film_category as fca
on ca.category_id = fca.category_id
INNER JOIN film as f
on f.film_id = fca.film_id
where ca.name IN ('Drama', 'Sports')
order by f.length desc
--4
select count(f.title), ca.name
from category as ca 
INNER JOIN film_category as fca
on ca.category_id = fca.category_id
INNER JOIN film as f
on f.film_id = fca.film_id
group by ca.name
order by count(f.title) DESC
--5 
select ac.first_name, ac.last_name, count(f.film_id)
from film_actor as fac
INNER JOIN film as f 
on fac.film_id = f.film_id
INNER JOIN actor as ac
on fac.actor_id = ac.actor_id
group by ac.first_name, ac.last_name
order by count(f.film_id) desc
--6
select ad.address, ad.address_id, c.address_id
from address as ad 
LEFT JOIN customer as c
ON ad.address_id = c.address_id
where c.address_id is null
--7
select city.city, sum(payment.amount)
from city 
inner join address
on city.city_id = address.city_id
inner join customer
on customer.address_id = address.address_id
inner join payment
on customer.customer_id = payment.customer_id
group by city.city
order by sum(payment.amount) desc
--8
select city.city||', '||country.country, sum(payment.amount)
from city 
inner join address
on city.city_id = address.city_id
inner join customer
on customer.address_id = address.address_id
inner join payment
on customer.customer_id = payment.customer_id
inner join country
on city.country_id = country.country_id
group by city.city||', '||country.country
order by sum(payment.amount) desc
