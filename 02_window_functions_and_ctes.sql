-- 13.What percentage of total sales comes from each category?
select category,sum(amount) as category_sale,sum(amount)/sum(sum(amount)) over()*100 
as percent from details group by category order by percent desc;
# collected percentage by category wise sales sum / its total *100

-- 14.Rank sub-categories by total sales using RANK().
select sub_category,amount,rank() over(order by amount desc) as sub_cat_rnk from details; 
-- 15.Rank sub-categories by total profit using DENSE_RANK().
select sub_category,profit,dense_rank() over(order by amount desc) as sub_cat_prt_rnk from details; 
-- 16.Find sub-categories whose sales are above the overall average using a subquery.
select sub_category,amount from details where amount >(select avg(amount) from details); 
-- 17.Find the contribution of each category to total sales using a CTE.
with cat_contribution as (select category,sum(amount) as sales from details group by category) select * from cat_contribution;

-- 18.Identify high-sales but low-profit sub-categories.
with sale_categorize as(select sub_category,sum(amount) as sales,sum(profit) as pro_fit,dense_rank() over(order by sum(amount) desc) as sale_rank,
dense_rank() over(order by sum(profit)) as profit_rank from details group by sub_category) select sub_category,sales,pro_fit,sale_rank,profit_rank from sale_categorize
where sale_rank<=(select count(distinct sub_category)/2 from details) and profit_rank<=(select count(distinct sub_category)/2 from details);

# got by selecting the total profit,total sales and ranked sales high to low and profit low to high and then take average rank by half of
# subcategory count. Then collected that much ranks of both. the  checked subcategory present in both rank list(low profit and high sale)
