--- tìm số lượng đơn hàng và số lượng khách hàng theo mỗi tháng từ 01/2019 tới 04/2022
with total_order_user_extract as (SELECT 
extract(year from created_at) as year,
extract(month from created_at) as month,
count(distinct user_id) as total_user,
count(order_id) as total_order
FROM (
  SELECT *
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE created_at BETWEEN '2019-01-01' AND '2022-05-01') as a
WHERE status = 'Complete'
group by extract(year from created_at), extract(month from created_at))

select 
year||'-'||month as month_year, 
total_user,
total_order 
from total_order_user_extract
order by year, month
Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng và đơn hàng tăng theo thời gian. 

--- giá trị đơn hàng trung bình (AOV) theo tháng
with b as (SELECT *
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE created_at BETWEEN '2019-01-01' AND '2022-05-01' and status = 'Complete')

, so_luong as (select extract(year from b.created_at) as year, extract(month from b.created_at) as month,
cast(sum(sale_price) as numeric) as total_amount,
count(distinct a.user_id) as distinct_user,
count(b.order_id)  as so_luong_don_hang
from b
left join bigquery-public-data.thelook_ecommerce.order_items as a
on b.order_id = a.order_id
group by extract(year from b.created_at), extract(month from b.created_at))

select year||'-'||month as year_month, 
distinct_user,
round(total_amount / so_luong_don_hang,2) as AOV
from so_luong
Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng distinct tăng theo thời gian, giá trị đơn hàng giao động ở mức $50-70/order.

--- Nhóm khách hàng theo độ tuổi
with customer as (Select 
first_name, last_name, gender, age,
case when age = (select min(age) from bigquery-public-data.thelook_ecommerce.users ) then 'youngest'
when age = (select max(age) from bigquery-public-data.thelook_ecommerce.users ) then 'oldest'
end as tag
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01')

,youngest_oldest as (select first_name, last_name, age, gender, tag
from customer
where tag = 'youngest' or tag ='oldest'
order by gender, age)

, age_insight as (select 
tag, gender, count(*)
from youngest_oldest
group by tag,gender
order by gender)

Nhận xét: 
-Tuổi nhỏ nhất: 12, tuổi lớn nhất: 70
-Số kh nữ nhỏ tuổi nhất: 543, số kh nam nhỏ tuổi nhất: 553, số kh nữ lớn tuổi nhất: 568, số kh nam lớn tuổi nhất: 542

--- top 5 sản phẩm có lợi nhuận cao nhất theo từng tháng 
with b as (SELECT extract(month from created_at) as month, extract(year from created_at) as year, order_id
  FROM bigquery-public-data.thelook_ecommerce.orders 
  WHERE created_at BETWEEN '2019-01-01' AND '2022-05-01' and status = 'Complete')

, c as (select b.month,b.year, p.id, p.name, sum(p.retail_price) as sales, sum(p.cost) as cost, sum(p.retail_price - p.cost) as profit
from b 
left join bigquery-public-data.thelook_ecommerce.order_items as oi on b.order_id = oi.order_id
left join bigquery-public-data.thelook_ecommerce.products as p on oi.product_id = p.id
group by  b.month,b.year, p.id, p.name )



, rank as (select month, year, id, name, sales, cost, profit, 
dense_rank()over(partition by year, month order by profit desc)as stt
from c)

select year||'-'||month as month_year,
id, name, sales, cost, profit, stt
from rank 
where stt <=5
order by year, month

--- doanh thu theo ngày của từng danh mục sản phẩm trong 3 tháng qua (ngày hiện tại là 15/04/2022)
SELECT  date(oi.created_at)as date,p.category as product_categories, 
sum(p.retail_price)-sum(p.cost) as revenue

from bigquery-public-data.thelook_ecommerce.order_items oi
LEFT JOIN bigquery-public-data.thelook_ecommerce.products p
on oi.product_id = p.id
where oi.order_id in (
                    SELECT order_id FROM `bigquery-public-data.thelook_ecommerce.orders` 
                    WHERE created_at BETWEEN '2022-01-15' AND '2022-04-15' and status = 'Complete'
)
group by date(oi.created_at), p.category
