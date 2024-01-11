--- create dataset
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
