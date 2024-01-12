--- create dataset theo yêu cầu
with main as (select
year||'-'||month as month,
year,
Product_category,
TPV, 
lag(TPV) over(partition by Product_category order by month, year) as TPV_pre,
TPO,
lag(TPO) over(partition by Product_category order by month, year) as TPO_pre,
total_cost,
TPV-total_cost as total_profit
from (
select 
extract(month from o.created_at) as month,
extract(year from o.created_at) as year,
p.category as Product_category,
SUM(retail_price) as TPV,
COUNT(o.order_id) as TPO,
SUM(p.cost) as total_cost
from bigquery-public-data.thelook_ecommerce.orders o
left join bigquery-public-data.thelook_ecommerce.order_items oi 
on o.order_id = oi.order_id
left join bigquery-public-data.thelook_ecommerce.products p
on oi.product_id = p.id
where o.created_at BETWEEN '2022-01-15' AND '2022-04-15' and o.status = 'Complete'
group by 1,2,3
order by 1,2,3) Table)

select
month, year, Product_category, TPV, TPO,
100*(TPV-TPV_pre)/TPV_pre||'%' as Revenue_growth,
100*(TPO-TPO_pre)/TPO_pre||'%' as Order_growth,
Total_cost,
Total_profit,
Total_profit/Total_cost as Profit_to_cost_ratio
from main

---cohort analysis
with index as (
      select 
      user_id,
      format_date('%Y-%m',first_purchase_date) as cohort_date,
      created_at,
      12*(extract(year from created_at) - extract(year from first_purchase_date))+
      (extract(month from created_at) - extract(month from first_purchase_date)) + 1 
      as indexx
from ( select user_id,
       MIN(created_at) over(partition by user_id) as first_purchase_date,
       created_at
       from bigquery-public-data.thelook_ecommerce.order_items))

, cohort as (select 
cohort_date,
indexx,
count(distinct user_id) as cnt
from index
group by cohort_date,indexx)

,customer_cohort as (select 
cohort_date, 
sum(case when indexx=1 then cnt else 0 end) as m1,
sum(case when indexx=2 then cnt else 0 end) as m2,
sum(case when indexx=3 then cnt else 0 end) as m3,
sum(case when indexx=4 then cnt else 0 end) as m4
from cohort
group by cohort_date)

---retention cohort
select cohort_date,
round(m1/m1*100.00,2)||'%' as m1,
round(m2/m1*100.00,2)||'%' as m2,
round(m3/m1*100.00,2)||'%' as m3,
round(m4/m1*100.00,2)||'%' as m4,
from customer_cohort
