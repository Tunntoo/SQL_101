SELECT * FROM public.sales_dataset_rfm_prj; 

---Changing column name format
ALTER TABLE sales_dataset_rfm_prj            
RENAME COLUMN ordernumber TO order_number; 

 --- changing column type to integer/numeric
ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN order_number TYPE integer USING (order_number::integer); 

ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN quantity_ordered TYPE integer USING (quantity_ordered::integer);

ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN price_each TYPE numeric USING (price_each::numeric);

ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN order_line_number TYPE integer USING (order_line_number::integer);

ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN sales TYPE numeric USING (sales::numeric);

ALTER TABLE sales_dataset_rfm_prj                                       
ALTER COLUMN msrp TYPE integer USING (msrp::integer);


---changing column type to timestamp
UPDATE sales_dataset_rfm_prj SET order_date = (TO_DATE(order_date, 'MM/DD/YYYY'));                          

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN order_date TYPE timestamp without time zone USING (order_date::timestamp without time zone);  

---chekcing for null/blank for order_number, price_each, order_line_number, sales, order_date
SELECT * FROM public.sales_dataset_rfm_prj                    
WHERE 
	order_number IS NULL or 
	quantity_ordered IS NULL or
	price_each IS NULL or
	order_line_number IS NULL or
	sales IS NULL or
	order_date IS NULL ; 

---adding column contact_last_name & contact_first_name with values extracted from contact_full_name 
ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN contact_last_name VARCHAR

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN contact_first_name VARCHAR

UPDATE public.sales_dataset_rfm_prj
SET contact_last_name = LEFT(contact_full_name,POSITION('-' in contact_full_name)-1)

UPDATE public.sales_dataset_rfm_prj
SET contact_first_name = SUBSTRING(contact_full_name FROM (POSITION('-' in contact_full_name)+1) FOR LENGTH(contact_full_name))

UPDATE sales_dataset_rfm_prj
SET contact_first_name =
UPPER(LEFT(contact_last_name,1))||RIGHT(contact_last_name,LENGTH(contact_last_name)-1)

UPDATE sales_dataset_rfm_prj
SET contact_first_name =
UPPER(LEFT(contact_first_name,1))||RIGHT(contact_first_name,LENGTH(contact_first_name)-1)

---adding QTR_ID, MONTH_ID, YEAR_ID with values extracted from order_date
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT
UPDATE sales_dataset_rfm_prj
SET QTR_ID = EXTRACT(QUARTER FROM order_date)

ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN MONTH_ID INT
UPDATE sales_dataset_rfm_prj
SET MONTH_ID =EXTRACT(MONTH FROM order_date) 

ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN YEAR_ID INT
UPDATE sales_dataset_rfm_prj
SET YEAR_ID =EXTRACT(YEAR FROM order_date) 

---find outliers using Percentile
with cte as (SELECT 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantity_ordered) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantity_ordered) AS Q3,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantity_ordered) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantity_ordered) AS IQR
FROM public.sales_dataset_rfm_prj), 

cte1 as (SELECT 
	Q1 - 1.5*IQR AS min,
	Q3 + 1.5*IQR AS max
	FROM cte),

outlier_percentile as (SELECT quantity_ordered 
			FROM public.sales_dataset_rfm_prj
			WHERE quantity_ordered < (SELECT min FROM cte1)	
			OR quantity_ordered > (SELECT max FROM cte1))
   
---find outliers using Z-score

with cte as (
	SELECT order_number, quantity_ordered, 
		(SELECT avg(quantity_ordered)
		FROM public.sales_dataset_rfm_prj) AS average,
		(SELECT stddev(quantity_ordered)
		FROM public.sales_dataset_rfm_prj) AS standard_dev
	FROM sales_dataset_rfm_prj),
	
outlier_Z_score as (
	SELECT quantity_ordered, (quantity_ordered-average)/standard_dev AS Z_score
	FROM cte
	WHERE ABS((quantity_ordered-average)/standard_dev) >3)

---clean the outliers by update the database
UPDATE public.sales_dataset_rfm_prj
SET quantity_ordered = (SELECT avg(quantity_ordered) FROM public.sales_dataset_rfm_prj)
WHERE quantity_ordered IN (SELECT quantity_ordered FROM outlier_percentile)
   
---clean the outliers by delete it from the database
DELETE FROM public.sales_dataset_rfm_prj
WHERE quantity_ordered IN (SELECT quantity_ordered FROM outlier_percentile)

---insert clean data into new table
SELECT * INTO SALES_DATASET_RFM_PRJ_CLEAN FROM sales_dataset_rfm_prj





	
