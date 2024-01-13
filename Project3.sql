--- Doanh thu theo từng Product_line, deal_size, year_id
select product_line, deal_size, year_id,
sum(sales)
from public.sales_dataset_rfm_prj_clean
group by product_line, deal_size, year_id
order by product_line, year_id, deal_size

--- Tháng có doanh thu lớn nhất mỗi năm
select month_id, sum(sales) as revenue, order_number
from public.sales_dataset_rfm_prj_clean
group by month_id, order_number
order by revenue DESC

--- Product line được bán nhiều ở tháng 11
select month_id, product_line, sum(sales) as revenue, order_number
from public.sales_dataset_rfm_prj_clean
where month_id = 11
group by month_id, product_line, order_number
order by revenue DESC

--- Xếp hạng sản phẩm có doanh thu tốt nhất ở UK mỗi năm
select year_id, product_line, revenue, 
dense_rank () over(partition by year_id order by revenue DESC) as rank
from(
select year_id, product_line, sum(sales) as revenue
from public.sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, product_line) a
  
/* Nhận xét
Trong năm 2003 và 2004, mặt hàng Classic Car có doanh thu lớn nhất chiếm ~35% tổng doanh thu cả năm. 
Tiếp đến là Vintage Car chiếm khoảng 28% hằng năm.
Trong năm 2005, có lẽ vì chưa đủ dữ liệu nên chỉ mới có những đơn hàng của Motocycles. 
*/
  
---Phân loại khách hàng
with customer_rfm as (select 
contact_full_name,
EXTRACT(days from (current_date - MAX(order_date))) as R,
count(*)/(EXTRACT(days from (current_date - MAX(order_date)))) as F,
sum(sales) as M
from public.sales_dataset_rfm_prj_clean
group by contact_full_name)

, rfm as (select contact_full_name,
ntile(5) over(order by r DESC) as r,
ntile(5) over(order by f DESC) as f,
ntile(5) over(order by m DESC) as m
from customer_rfm)

, rfm_score as (select contact_full_name,
cast (r as varchar)||cast (m as varchar)||cast (f as varchar) as rfm_score
from rfm)

select contact_full_name, segment
from rfm_score a join segment_score b
on a.rfm_score=b.score

  /*nhận xét: 
Tổng quan khách hàng:
- New Customer chiếm khoảng 20% và Potential Loyalist chiếm 5% <- cần chú ý đến nhóm khách hàng này để convert họ thành loyalist
  Stategy: cải thiện customer service để tăng customer satisfaction, cho họ early access vào các mùa sales hoặc sản phẩm mới. Áp dụng một số ưu đãi khuyến mãi.
- Champion (5%) và Loyal (10%) <- nhóm khách hàng trung thành. Với nhóm này nên tăng các chương trình loyalty reward, upsell higher value product, referrals.
- Nhóm Can't Lose Them, At Risk and Need Attention chiếm khoảng 30% <- đây là nhóm khách hàng cần được tập trung xây dựng các chiến dịch có tính personalize cao.
  Đặc biệc nhóm Can't Lose Them và At Risk chiếm khoảng 20%, có thể sử dụng renewals program, quảng bá các sản phẩm mới. 
- Nhóm Hibernating customer chiếm khoảng 18% <- cần giữ chân bằng các standard email communication nhưng ko oversend. 
- Ngoài ra nhóm Promising chiếm khoảng 5%, nên include họ vào các promition và personalize email để tăng tính tương tác
- Có 1% lost customer. 
*/
