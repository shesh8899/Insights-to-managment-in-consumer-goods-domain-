
#q1
SELECT market FROM dim_customer WHERE customer="Atliq Exclusive" and region="APAC";
#q2
with cte1 as (SELECT count(distinct(product)) as unique_products_2020 FROM dim_product JOIN fact_sales_monthly USING(product_code) WHERE fiscal_year=2020),cte2 
as(SELECT count(distinct(product)) as unique_products_2021 FROM dim_product JOIN fact_sales_monthly USING(product_code) WHERE fiscal_year=2021)
 SELECT unique_products_2020,unique_products_2021,ROUND((unique_products_2021-unique_products_2020)*100/unique_products_2020,2)  as percentage_change FROM cte1 JOIN cte2 ;
#Q3
SELECT segment,COUNT(DISTINCT(product)) as product_count FROM dim_product GROUP BY segment;
#q4
with cte1 as (SELECT segment,COUNT(distinct(product)) as product_count_2020 from dim_product JOIN fact_sales_monthly USING(product_code)
 WHERE fiscal_year=2020 GROUP BY segment),
cte2 as (SELECT segment,COUNT(distinct(product)) as product_count_2021 
from dim_product JOIN fact_sales_monthly USING(product_code) WHERE fiscal_year=2021 GROUP BY segment)
SELECT c1.segment,product_count_2020,product_count_2021,(product_count_2021-product_count_2020) as diffrence FROM cte1 c1 JOIN cte2 USING(segment);
#q5
(SELECT p.product_code,p.product,ROUND(AVG(manufacturing_cost),2) as manufacture_cost FROM dim_product p JOIN fact_manufacturing_cost m USING(product_code) group by product,product_code ORDER BY AVG(manufacturing_cost) DESC LIMIT 1 )
UNION 
(SELECT p.product_code,p.product,ROUND(AVG(manufacturing_cost),2) as manufacture_cost FROM dim_product p JOIN fact_manufacturing_cost m USING(product_code) group by product,product_code ORDER BY AVG(manufacturing_cost)  LIMIT 1);
#q6
SELECT c.customer,s.customer_code,ROUND(AVG(d.pre_invoice_discount_pct)*100,2) as average_discount_percentage FROM fact_sales_monthly s JOIN fact_pre_invoice_deductions d ON s.customer_code=d.customer_code and get_fiscal_year(s.date)=d.fiscal_year 
JOIN dim_customer c ON d.customer_code=c.customer_code WHERE get_fiscal_year(date)=2021 GROUP BY s.customer_code,c.customer ORDER BY  average_discount_percentage DESC LIMIT 5 ;
#q7
SELECT MONTH(date) as month,YEAR(date) as year,ROUND(SUM(gross_price*sold_quantity),2) as gross FROM fact_sales_monthly s 
JOIN fact_gross_price g USING(product_code) JOIN dim_customer USING(customer_code) WHERE customer="Atliq Exclusive" GROUP BY MONTH(date),YEAR(date);
#q8
SELECT get_quarter(date) as quater,SUM(sold_quantity) as sold_qunatity FROM fact_sales_monthly WHERE YEAR(date)=2020  
GROUP BY get_quarter(date) ORDER BY SUM(sold_quantity) DESC;
#q9
with cte1 as(SELECT channel,SUM(sold_quantity*gross_price) as gross_sales_mln FROM fact_sales_monthly s JOIN 
 dim_customer c USING(customer_code) JOIN fact_gross_price g USING(product_code) GROUP BY channel)
 SELECT channel,ROUND(gross_sales_mln/1000000,2) as grs_sales_mln,ROUND(gross_sales_mln*100/SUM(gross_sales_mln) OVER() ,2)AS pct FROM cte1;
 #q10
 with cte1 as (SELECT p.division,s.product_code,product,SUM(sold_quantity) as total_sold_quantity FROM fact_sales_monthly s JOIN dim_product p USING(product_code) GROUP BY s.product_code,p.division,product) 
 ,cte2 as(SELECT division,product_code,product,total_sold_quantity,dense_rank() OVER(partition by division  ORDER by total_sold_quantity DESC ) as rank_order FROM cte1 GROUP BY product_code,division,product)
 SELECT division,product_code,product,total_sold_quantity,rank_order FROM cte2 WHERE rank_order IN(1,2,3) GROUP BY product_code,division,product;
 
 
 




