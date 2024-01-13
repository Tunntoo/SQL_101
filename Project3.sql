--- Doanh thu theo từng Product_line, deal_size, year_id
select product_line, deal_size, year_id,
sum(sales)
from public.sales_dataset_rfm_prj_clean
group by product_line, deal_size, year_id
order by product_line, year_id, deal_size
