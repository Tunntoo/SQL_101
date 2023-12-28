--1 
with cte as (select 
customer_id, 
order_date,
customer_pref_delivery_date,
case 
when customer_pref_delivery_date - order_date = 0 then 'immediate' else 'scheduled'
end as type,
row_number() over(partition by customer_id order by order_date) as stt
from Delivery)

select 
round(100*sum(case when type = 'immediate' then 1 else 0 end) / count(type),2) as immediate_percentage
from cte
where stt = 1

--2
with cte as (select
player_id, 
datediff(event_date, min(event_date) over(partition by player_id)) = 1 as diff
from activity)

select 
round(sum(diff) / count(distinct player_id) ,2) as fraction
from cte

--3
select 
case 
    when id = (SELECT MAX(id) FROM Seat) and id%2 <> 0 then id
    when id%2 = 0 then id-1
    else id+1
end as id,
student
from Seat
order by id

--4
with cte as (select
visited_on, 
sum(amount) as amount
from Customer
group by visited_on),

cal as (select 
visited_on,
sum(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 preceding and current row) as amount,
round(avg(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS avg_amount,
row_number () over(order by visited_on) as ranking
from cte)

select 
visited_on, amount, avg_amount as average_amount
from cal
where ranking >6

--5
with cte as (select 
pid, tiv_2015, tiv_2016,
concat(lat,'-',lon),
count(concat(lat,'-',lon)) over(partition by concat(lat,'-',lon)) as count
from Insurance)

select 
round(sum(tiv_2016),2) as tiv_2016
from Insurance
where tiv_2015 = (select 
tiv_2015
from Insurance 
group by tiv_2015
having count(tiv_2015) > 1) and pid IN (select pid
from cte 
where count =1)

--6
WITH CTE AS (select 
Department.name as Department,
Employee.name as Employee, 
Employee.salary as Salary,
DENSE_RANK() OVER(PARTITION BY Department.name order by Employee.salary Desc) as ranking
from Employee
join Department 
on Employee.departmentId=Department.id)

SELECT Department, Employee, Salary 
from CTE
where ranking <=3

--7
with cte as (select 
turn, 
person_id,
person_name,
weight, 
SUM(weight) over(order by turn)  as Total_Weight
from Queue),

cte1 as (select 
person_name,
Total_Weight
from cte
where Total_Weight <= 1000 )

select person_name 
from cte1 
where Total_Weight = (Select Max(Total_Weight) from cte1)

--8
select
product_id, 10 as price
from Products
group by product_id
having MIN(change_date) > '2019-08-16'
UNION
select product_id, new_price as price 
from Products
where (product_id, change_date) IN
(select
product_id, 
MAX(change_date) as change_date
from Products
where change_date <= '2019-08-16'
group by product_id)
