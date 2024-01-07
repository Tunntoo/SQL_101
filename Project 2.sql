/*check null
select * from bigquery-public-data.thelook_ecommerce.orders
where order_id is null or
user_id is null or
status is null or
created_at is null

select * from bigquery-public-data.thelook_ecommerce.order_items
where order_id is null or
user_id is null or
status is null or
product_id is null
*/

--- tìm số lượng đơn hàng và số lượng khách hàng theo mỗi tháng từ 01/2019 tới 04/2022
select year||"-"||month as month_year, total_user, total_order 
from (
      select count(order_id) as total_order, 
      count(distinct user_id) as total_user, extract(year from created_at) as year, extract(month from created_at) as month 
      from 
      bigquery-public-data.thelook_ecommerce.orders
      where created_at BETWEEN '2019-01-02' AND '2022-05-01' AND status = 'Complete'
      group by 3, 4
      order by 3, 4) Table 

Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng và đơn hàng tăng theo thời gian và tăng khá đồng đều
  

--- giá trị đơn hàng trung bình (AOV) theo tháng
select year||'-'||month as month_year, distinct_users, average_order_value
from(
    select count(distinct o.user_id) as distinct_users,avg(oi.sale_price)as average_order_value, 
    extract(year from o.created_at) as year, extract(month from o.created_at) as month from 
    bigquery-public-data.thelook_ecommerce.orders as o
    left join bigquery-public-data.thelook_ecommerce.order_items as oi
    on o.order_id = oi.order_id
    where o.created_at BETWEEN '2019-01-02' AND '2022-05-01' AND o.status = 'Complete'
    group by 3,4
    order by 3,4)
Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng distinct tăng theo thời gian, giá trị đơn hàng đạt mức cao nhất vào tháng 3/2019 nhưng sau đó giữ ở mức ~$50-70 trong những tháng tiếp theo.

--- Nhóm khách hàng theo độ tuổi
with age as (select first_name, last_name, gender, age, tag
from (
    select first_name, last_name, o.gender as gender, age,
      case 
        when age = (select min(age) from bigquery-public-data.thelook_ecommerce.users) then 'youngest'
        when age = (select max (age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest'
      end as tag
    from 
    bigquery-public-data.thelook_ecommerce.orders as o
    left join bigquery-public-data.thelook_ecommerce.users as u
    on o.user_id = u.id
    where o.created_at BETWEEN '2019-01-02' AND '2022-05-01' AND o.status = 'Complete'
) table
where tag is not null
order by gender, age)

select gender, tag, count(*) as so_luong from age
group by gender, tag

Nhận xét: 
-Tuổi nhỏ nhất: 12, tuổi lớn nhất: 70
------------------------------------------
|  gender    |    tag        |  so_luong |
------------------------------------------
|  F         |    oldest     |  69       |
------------------------------------------
|  F         |    youngest   |  95       |
------------------------------------------
|  M         |    youngest   |  63       |
------------------------------------------
|  M         |    oldest     |  76       |
------------------------------------------

      --- top 5 sản phẩm có lợi nhuận cao nhất theo từng tháng 
with ranking_product_profit as (select year||'-'||month as month_year, product_id, product_name, sales, cost, profit,
dense_rank () over(partition by year, month order by profit) as rank
from (
select product_id, product_name, sum(product_retail_price) as sales, sum(cost)as cost, sum(product_retail_price)-sum(cost) as profit
,extract (year from sold_at) as year, extract (month from sold_at) as month
from 
bigquery-public-data.thelook_ecommerce.inventory_items
where sold_at is not null 
group by year, month, product_id, product_name) Table
)

select month_year, product_id, product_name, sales, cost, profit, rank
from ranking_product_profit
where rank <= 5

--- doanh thu theo ngày của từng danh mục sản phẩm trong 3 tháng qua (ngày hiện tại là 15/04/2022)

/* check null:
select * from bigquery-public-data.thelook_ecommerce.inventory_items
where 
product_id is null 
or product_retail_price is null
or cost is null */

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
