create database project1;
use project1;
-- 1. How many unique orders are present in the dataset?
select count(distinct Order_ID) from details;
-- 2. What is the total sales amount generated?
select sum(amount) from details;
-- 3. What is the total profit generated?
select sum(profit) from details;
-- 4. What is the total quantity of products sold? 
select sum(Quantity) from details;
-- 5. What are the different product sub-categories in each category available? 
select distinct category,sub_category from details order by category,sub_category;
-- 6. Which product category generates the highest sales?
select category,sum(amount) as sales from details group by category order by sales desc limit 1;
-- 7.Which product category generates the highest profit?
select category,sum(profit) as pro_sal from details group by category order by pro_sal desc limit 1;
-- 8.Which sub-category has the highest quantity sold?
select sub_category,sum(quantity) as sold from details group by sub_category order by sold desc limit 1;
-- 9.Which sub-categories generate more 5000 profit?
select sub_category,sum(profit) as sales from details  group by sub_category having sales>5000 order by sales desc;
-- 10.Which payment mode is used most frequently?
select paymentmode,count(*) as used from details group by paymentmode order by used desc limit 1;
-- 11.What is the average order value for each payment mode?
select paymentmode,avg(amount) as aver from details group by paymentmode order by aver desc;
-- 12.Which category has the highest average profit per order?
select category,avg(profit) as avrg from details group by category order by avrg desc;


