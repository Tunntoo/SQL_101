--1
with CTE as (
  SELECT company_id, title, description, count(job_id) as so_luong
  FROM job_listings
  group by company_id, title, description) 

select count(company_id) as duplicate
from CTE
where CTE.so_luong >1
  
--2
with app as(
  select category, product, sum(spend) as total_spend
  from product_spend
  where category = 'appliance' AND extract(year from transaction_date)=2022
  group by category, product
  order by sum(spend) DESC
  limit 2),

elec as (
  select category, product, sum(spend) as total_spend
  from product_spend
  where category = 'electronics' AND extract(year from transaction_date)=2022
  group by category, product
  order by sum(spend) DESC
  limit 2)

select category, product, total_spend from app
UNION select category, product, total_spend from elec 
order by category, total_spend desc
  
--3 phần này hình như đề bị lỗi nên mình không chạy được câu lệnh ạ!
select count(policy_holder_id) as member_count 
from
  (select policy_holder_id, count(case_id)
  from callers
  group by policy_holder_id
  having count(case_id) >= 3) as call_record
  
--4
with cte as (
  select p.page_id, plike.user_id, plike.page_id as like_id
  from pages as p
  left join page_likes as plike
  on p.page_id = plike.page_id)

select page_id from cte
where user_id is NULL
order by page_id
  
--5
with july as(
  select distinct user_id, extract(month from event_date) as month
  from user_actions 
  where extract(month from event_date) = 7
  group by extract(month from event_date), user_id
  order by user_id),

june as (
  select distinct user_id, extract(month from event_date) as month
  from user_actions 
  where extract(month from event_date) = 6
  group by extract(month from event_date), user_id
  order by user_id)


select july.month, count (july.user_id) as monthly_active_users
from july left join june
on july.user_id = june.user_id
where june.user_id is not NULL
group by july.month
  
--6
with cte as (
  select trans_date, country, id,
  state,
  sum(amount) as approved_total_amount
  from Transactions
  where state = 'approved'
  group by extract(month from trans_date), country, id, state)

select
  date_format (T.trans_date, '%Y-%m') as month,
  T.country, 
  count(T.id) as trans_count,
  count(cte.state) as approved_count, 
  sum(T.amount) as trans_total_amount, 
  COALESCE(sum(cte.approved_total_amount),0) as approved_total_amount
from Transactions as T 
left join cte 
on T.id = cte.id
group by MONTH(T.trans_date)+'-'+YEAR(T.trans_date), country

--7
with cte as(
  select product_id, min(year) as first_year
  from sales 
  where product_id = sales.product_id
  group by product_id
)

select 
cte.product_id, 
cte.first_year,
sales.quantity,
sales.price
from cte left join sales on cte.product_id = sales.product_id and cte.first_year=sales.year

--8

