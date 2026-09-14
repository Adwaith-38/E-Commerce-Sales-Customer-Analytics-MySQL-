# E-Commerce Sales & Business Analytics (MySQL) 
 
## Project Overview 
 
An end-to-end SQL data analytics project analyzing transactional e-commerce order details. The project evaluates product category performance, profitability margins, payment methods, and sales-target performance against manager benchmarks using MySQL. 
 
## Dataset & Data Sources 
 
* **`details` (Transactions Data)**: Sourced and downloaded as a CSV dataset from **Kaggle** (e-commerce sales/order dataset) and imported into MySQL. It contains transactional records including `Order_ID`, `amount`, `profit`, `quantity`, `category`, `sub_category`, and `paymentmode`. 
 
 
* **`category_targets` (Custom Benchmark Table)**: A custom relational dimension table created manually within MySQL to simulate business target tracking. It maps each product `category` to an assigned `manager_name` and quota benchmark `target_sales`. 
 
 
 
## Database Schema & Design 
 
``` 
+------------------------------------+          +---------------------------------+ 
|              details               |          |        category_targets         | 
|         (From Kaggle CSV)          |          |        (Custom Created)         | 
+------------------------------------+          +---------------------------------+ 
| Order_ID     VARCHAR / INT         |          | category (PK)   VARCHAR(20)     | 
| amount       DECIMAL / INT         |          | manager_name    VARCHAR(20)     | 
| profit       DECIMAL / INT         |    +---->| target_sales    INT             | 
| quantity     INT                   |    |     +---------------------------------+ 
| category     VARCHAR(50)  ---------+----+ 
| sub_category VARCHAR(50)           | 
| paymentmode  VARCHAR(20)           | 
+------------------------------------+ 
 
``` 
 
--- 
 
## Tools & SQL Skills
 
* **Database Engine**: MySQL Server 
 
 
* **Database Client**: MySQL Workbench / Command Line Client 
 
 
* **Language**: SQL (Data Definition Language, Data Manipulation Language, Common Table Expressions, Window Functions, Stored Procedures, Views) 
 
 
### SQL Techniques
- Aggregate Functions & GROUP BY
- INNER & RIGHT JOINs
- CASE WHEN
- Subqueries
- CTEs
- Window Functions
- RANK() & DENSE_RANK()
- Views
- Stored Procedures
- NULLIF() & Defensive Calculations 
--- 
 
## Key Business Questions Answered 
 
### 1. High-Sales but Low-Profit Sub-Categories 
 
* **Business Intent**: Identify sub-categories that generate high sales but yield poor profits, exposing operational inefficiencies or low-margin dependencies. 
 
 
* **Technique**: Common Table Expressions (CTE), Window Ranking Functions (`DENSE_RANK()`), Subqueries. 
 
 
 
```sql 
WITH sale_categorize AS ( 
    SELECT  
        sub_category, 
        SUM(amount) AS sales, 
        SUM(profit) AS pro_fit, 
        DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS sale_rank, 
        DENSE_RANK() OVER (ORDER BY SUM(profit) ASC) AS profit_rank  
    FROM details  
    GROUP BY sub_category 
)  
SELECT  
    sub_category, 
    sales, 
    pro_fit, 
    sale_rank, 
    profit_rank  
FROM sale_categorize 
WHERE sale_rank <= (SELECT COUNT(DISTINCT sub_category)/2 FROM details)  
  AND profit_rank <= (SELECT COUNT(DISTINCT sub_category)/2 FROM details); 
 
``` 
 
--- 
 
### 2. Category Performance vs. Sales Targets 
 
* **Business Intent**: Evaluate department managers' performance by comparing realized sales against target KPIs. 
 
 
* **Technique**: `INNER JOIN`, Aggregate Functions, Conditional `CASE` Logic. 
 
 
 
```sql 
SELECT  
    c.category, 
    c.manager_name, 
    SUM(d.amount) AS total_sales, 
    c.target_sales, 
    CASE  
        WHEN SUM(d.amount) >= c.target_sales THEN 'Target achieved'  
        ELSE 'Target missed'  
    END AS status 
FROM details AS d  
JOIN category_targets AS c  
    ON d.category = c.category  
GROUP BY c.category, c.manager_name, c.target_sales; 
 
``` 
 
--- 
 
### 3. Sales Percentage Contribution by Category 
 
* **Business Intent**: Measure revenue concentration across product categories to determine portfolio dependence. 
 
 
* **Technique**: Aggregate Window Functions (`SUM() OVER()`). 
 
 
 
```sql 
SELECT  
    category, 
    SUM(amount) AS category_sale, 
    ROUND(SUM(amount) / SUM(SUM(amount)) OVER() * 100, 2) AS percent  
FROM details  
GROUP BY category  
ORDER BY percent DESC; 
 
``` 
 
--- 
 
### 4. Profitability Classification: Profit, Low Profit, and Loss 
 
* **Business Intent**: Classify merchandise sub-categories into risk tiers based on profit margin percentage. 
 
 
* **Technique**: Data categorization with `CASE WHEN`, zero-division protection using `NULLIF()`. 
 
 
 
```sql 
SELECT  
    sub_category, 
    SUM(profit) AS profit, 
    SUM(amount) AS sales, 
    ROUND((SUM(profit) * 100.0) / NULLIF(SUM(amount), 0), 2) AS profit_margin_pct, 
    CASE  
        WHEN (SUM(profit) * 100.0) / NULLIF(SUM(amount), 0) < 0 THEN 'Loss' 
        WHEN (SUM(profit) * 100.0) / NULLIF(SUM(amount), 0) < 10 THEN 'Low Profit'  
        ELSE 'Profit'  
    END AS profitability  
FROM details  
GROUP BY sub_category  
ORDER BY profit_margin_pct DESC; 
 
``` 
 
--- 
 
### 5. Cash on Delivery (COD) Order Distribution 
 
* **Business Intent**: Identify which sub-category handles the highest volume of COD orders and calculate the proportion of cash transactions for cashflow and logistics tracking. 
 
 
* **Technique**: Conditional Aggregation (`SUM(CASE ...)`), Proportional Ratio Calculation. 
 
 
 
```sql 
SELECT  
    sub_category, 
    SUM(CASE WHEN LOWER(paymentmode) = 'cod' THEN 1 ELSE 0 END) AS cod_orders, 
    COUNT(order_id) AS total_order, 
    ROUND(SUM(CASE WHEN LOWER(paymentmode) = 'cod' THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS percent 
FROM details  
GROUP BY sub_category  
ORDER BY cod_orders DESC  
LIMIT 1; 
 
``` 
 
--- 
 
### 6. Analytical View for Category Metrics 
 
* **Business Intent**: Expose a clean, reusable data interface for reporting and BI tools containing category-level sales, quantities, profits, and profit margins. 
 
 
* **Technique**: Database Views (`CREATE VIEW`), Defensive Margin Calculation. 
 
 
 
```sql 
CREATE VIEW category_analyse AS  
SELECT  
    category, 
    SUM(amount) AS sales, 
    SUM(profit) AS pro_fit, 
    SUM(quantity) AS quantity, 
    CASE  
        WHEN SUM(amount) > 0 THEN (SUM(profit) / SUM(amount)) * 100  
        ELSE 0  
    END AS profit_margin  
FROM details  
GROUP BY category; 
 
``` 
 
--- 

## Key Insights

- Identified sub-categories with high sales but comparatively low profitability.
- Compared actual category sales against custom management targets to identify target achievement and shortfalls.
- Measured each category's contribution to overall sales.
- Classified sub-categories into Profit, Low Profit, and Loss based on profit margin.
- Identified the sub-category with the highest COD order volume.


---

## What I Learned 
 
* Structured complex analytical queries using **Common Table Expressions (CTEs)** and **Window Functions** (`DENSE_RANK()`, `SUM() OVER()`) to perform multi-step business ranking and category-to-total percentage analysis. 
 
 
* Built relational target-tracking queries by designing custom reference tables and using **table joins** (`INNER JOIN`, `RIGHT JOIN`) and conditional `CASE` statements to evaluate KPI achievement against manager benchmarks. 
 
 
* Implemented modular SQL structures by authoring persistent **views** and **stored procedures** to deliver ready-to-consume datasets for downstream dashboards.

---

## Future Improvements

- Build an interactive Power BI dashboard using the MySQL analytical view.
- Extend the dataset with customer identifiers to enable customer-level analysis, retention, and lifetime value analysis.
- Add time-based analysis for monthly and yearly sales trends.
- Expand the schema with customer, product, and logistics dimensions.
