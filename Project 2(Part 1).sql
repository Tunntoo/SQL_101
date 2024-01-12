
/*check null
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE order_id IS NULL
OR user_id IS NULL 
OR status IS NULL
OR created_at IS NULL

SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE order_id IS NULL
OR user_id IS NULL 
OR status IS NULL 
OR product_id IS NULL
*/

--- tìm số lượng đơn hàng và số lượng khách hàng theo mỗi tháng từ 01/2019 tới 04/2022
SELECT 
      YEAR||"-"||MONTH AS month_year, 
      total_user, 
      total_order 
      FROM (
            SELECT COUNT(order_id) AS total_order, 
            COUNT(DISTINCT user_id) AS total_user, 
            EXTRACT(YEAR FROM created_at) AS year, EXTRACT(MONTH FROM created_at) AS month 
            FROM bigquery-public-data.thelook_ecommerce.orders
            WHERE created_at BETWEEN '2019-01-02' AND '2022-05-01' AND status = 'Complete'
            GROUP BY 3, 4
            ORDER BY 3, 4) Table 

Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng và đơn hàng tăng theo thời gian và tăng khá đồng đều
  

--- giá trị đơn hàng trung bình (AOV) theo tháng
SELECT 
      YEAR||'-'||MONTH AS month_year, 
      distinct_users, 
      average_order_value
      FROM(
          SELECT 
            COUNT(DISTINCT o.user_id) AS distinct_users,
            AVG(oi.sale_price) AS average_order_value, 
            EXTARCT(YEAR FROM o.created_at) AS year, 
            EXTRACT(MONTH FROM o.created_at) AS month 
            FROM bigquery-public-data.thelook_ecommerce.orders AS o
                LEFT JOIN bigquery-public-data.thelook_ecommerce.order_items AS oi
                ON o.order_id = oi.order_id
                WHERE o.created_at BETWEEN '2019-01-02' AND '2022-05-01' AND o.status = 'Complete'
                GROUP BY 3,4
                ORDER BY 3,4)
Nhận xét: từ khoảng 01/2019 tới 04/2022, số lượng khách hàng distinct tăng theo thời gian, giá trị đơn hàng đạt mức cao nhất vào tháng 3/2019 nhưng sau đó giữ ở mức ~$50-70 trong những tháng tiếp theo.

--- Nhóm khách hàng theo độ tuổi
WITH age AS (
      SELECT first_name, last_name, gender, age, tag
      FROM (
                SELECT first_name, last_name, o.gender AS gender, age,
                  CASE 
                    WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users) THEN 'youngest'
                    WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users) THEN 'oldest'
                  END AS tag
                FROM bigquery-public-data.thelook_ecommerce.orders AS o
                LEFT JOIN bigquery-public-data.thelook_ecommerce.users AS u
                ON o.user_id = u.id
                WHERE o.created_at BETWEEN '2019-01-02' AND '2022-05-01' AND o.status = 'Complete'
            ) table
WHERE tag IS NOT NULL
ORDER BY gender, age)

SELECT gender, tag, COUNT(*) AS so_luong 
FROM age
GROUP BY gender, tag

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
WITH ranking_product_profit AS (
      SELECT 
      YEAR||'-'||MONTH AS month_year, 
      product_id, product_name, sales, cost, profit,
      dense_rank () over(partition BY year, month ORDER BY profit) AS rank
      FROM(
            SELECT product_id, product_name, SUM(product_retail_price) AS sales, 
                  SUM(cost) AS cost, 
                  SUM(product_retail_price)-sum(cost) AS profit,
                  EXTRACT (YEAR FROM sold_at) AS year, EXTRACT (MONTH FROM sold_at) AS month
            FROM bigquery-public-data.thelook_ecommerce.inventory_items
            WHERE sold_at IS NOT NULL 
            GROUP BY year, month, product_id, product_name) Table
            )

SELECT month_year, product_id, product_name, sales, cost, profit, rank
FROM ranking_product_profit
WHERE rank <= 5

--- doanh thu theo ngày của từng danh mục sản phẩm trong 3 tháng qua (ngày hiện tại là 15/04/2022)

/* check null:
SELECT * FROM bigquery-public-data.thelook_ecommerce.inventory_items
WHERE 
product_id IS NULL 
OR product_retail_price IS NULL
OR cost IS NULL */

SELECT  DATE(oi.created_at) AS date, p.category AS product_categories, 
        SUM(p.retail_price)-SUM(p.cost) AS revenue

FROM bigquery-public-data.thelook_ecommerce.order_items oi
LEFT JOIN bigquery-public-data.thelook_ecommerce.products p
ON oi.product_id = p.id
WHERE oi.order_id IN (
                    SELECT order_id FROM `bigquery-public-data.thelook_ecommerce.orders` 
                    WHERE created_at BETWEEN '2022-01-15' AND '2022-04-15' and status = 'Complete'
                        )
GROUP BY date(oi.created_at), p.category
