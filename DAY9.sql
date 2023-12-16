--1
SELECT 
SUM(CASE 
  WHEN device_type = 'laptop' THEN 1 ELSE 0
END) as laptop_views,
SUM(CASE
  WHEN device_type IN ('phone', 'tablet') THEN 1 ELSE 0
END) as mobile_views
FROM viewership
--2
select x, y, z,
CASE 
    WHEN x+y>z and y+z>x and x+z>y THEN 'Yes' ELSE 'No'
END as triangle
from Triangle
--3
SELECT
   ROUND(
   SUM(CASE WHEN call_category IS NULL OR call_category = 'n/a' 
            THEN 1 
            ELSE 0
    END) /COUNT(call_category)*100, 1)
FROM callers
--4
select name
from Customer
where referee_id != 2 or referee_id IS NULL
--5
select 
survived,
sum(case
    when pclass= 1 then 1 else 0
end) as first_class,
sum(case
    when pclass= 2 then 1 else 0
end) as second_class,
sum(case
    when pclass= 3 then 1 else 0
end) as third_class

from titanic
group by survived
