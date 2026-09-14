-- 19.Create a view containing category-level sales, quantity, profit and profit margin.
create view category_analyse as select category,sum(amount) as sales,sum(profit) as pro_fit,sum(quantity) as quantity,
case when sum(amount)>0 then sum(profit)/sum(amount)*100 else 0 end as profit_margin from details group by category;

-- 20. How many sub-categories fall into each profitability group: Profit, Low Profit, and Loss?
select sub_category,sum(profit) as profit,sum(amount) as sales,(sum(profit)*100.0)/nullif(sum(amount),0) as percent,
case when (sum(profit)*100.0)/nullif(sum(amount),0)<0 then 'Loss'
 when (sum(profit)*100.0)/nullif(sum(amount),0)<10 then 'low profit' else 'profit' end as profitability from details group by sub_category;

-- 21.Which sub-category has the highest number of COD orders, and what percentage of its total orders are COD?
select sub_category,sum(case when paymentmode='cod'then 1 else 0 end) as cod_orders,count(order_id) as total_order,
round(sum((case when paymentmode='cod' then 1 else 0 end)*100.0)/count(order_id),2) as percent
 from details group by sub_category order by cod_orders desc limit 1;
 
 -- 22.create a stored procedure that collect total sales,total profit,total quantity,total order count for each subcategory
 delimiter // 
 create procedure subcategory_details()
 begin
 select sub_category,sum(amount) as total_sales from details group by sub_category;
 select sub_category,sum(profit) as total_profit from details group by sub_category;
 select sub_category,sum(quantity) as total_quantity from details group by sub_category;
 select sub_category,count(distinct 'order_id') as total_order_count from details group by sub_category;
 end //
 delimiter ;
call subcategory_details();


-- creating another table for joins
create table category_targets(category varchar(20) primary key,target_sales int,manager_name varchar(20));
insert into category_targets values('Clothing', 150000, 'Hari'),('Electronics', 200000, 'Syam'),
('Furniture', 120000, 'Rohan Verma'),('Books',15000,'Dhanush');


-- 23. Join the sales data with the category targets table to display each category, its manager, total sales achieved, target sales
select c.category,c.manager_name,sum(d.amount) as total_sales,c.target_sales,case when sum(d.amount)>= c.target_sales then 'Target achieved' 
else 'Target missed' end as status
from details as d join category_targets as c on d.category=c.category group by category;

-- 24.List all categories and their assigned managers alongside total profit generated, 
-- including categories that might not have recorded any sales yet
select c.category,c.manager_name,sum(d.profit) as total_profit
from details as d right join category_targets as c on d.category=c.category group by category;