---baitap1
SELECT NAME FROM CITY
WHERE COUNTRYCODE = 'USA'
AND POPULATION >120000
  
---baitap2
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN'
  
---baitap3
SELECT CITY, STATE FROM STATION
  
---baitap4
SELECT DISTINCT CITY FROM STATION
WHERE 
CITY LIKE 'a%' 
OR CITY LIKE 'e%' 
OR CITY LIKE 'i%'
OR CITY LIKE 'o%'
OR CITY LIKE 'u%'
  
---baitap5
select distinct city from station
where city rlike '^.*[ueoaiUEOAI]$'
  
---baitap6
SELECT DISTINCT CITY 
FROM STATION 
WHERE CITY NOT RLIKE '^[aeiouAEIOU].*$'
  
---baitap7
SELECT NAME FROM EMPLOYEE
ORDER BY NAME
  
---baitap8
select name from employee 
where salary >2000 
and months <10
order by employee_id

---baitap9
select product_id from Products
where low_fats = 'Y'
and recyclable = 'Y'

---baitap10
select name from customer
where referee_id <> 2 or referee_id is null

---baitap11
select name, population, area from World 
where area >= 3000000 or
population >= 25000000

---baitap12
select distinct author_id as id from Views
where viewer_id = author_id
order by  author_id

---baitap13
SELECT part, assembly_step FROM parts_assembly
where finish_date is null

---baitap14
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary >= 70000

---baitap15
select * from uber_advertising
where year = 2019 and money_spent >100000
