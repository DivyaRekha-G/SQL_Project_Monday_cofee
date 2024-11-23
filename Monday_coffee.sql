create database Monday_coffee;
use monday_coffee;
create table City
 (city_id int primary key,
 city_name varchar(15),
 population bigint,
 estimated_rent float,
 city_rank int);
 
 Create table Customers
 (customer_id int primary key,
 customer_name varchar(25),
 city_id int,
 constraint fk_city foreign key(city_id) references city(city_id)
 );
 
 Create table Products
 (product_id int primary key,
 product_name varchar(40),
 price float
 );
 
 Create Table Sales
 (sales_id int,
 sales_date date,
 product_id int,
 customer_id int,
 Total float,
 rating int,
 constraint fk_products Foreign key (product_id) references products(product_id),
 constraint fk_customers foreign key (customer_id) references customers(customer_id)
 );
 
 desc city;
 -- Data Analysis
 
 select * from city;
 select * from products;
 select * from customers;
 select * from sales;
 
 -- REPORTS AND DATA ANALYSIS
 -- Q1.Coffe consumer count
 -- how many people in each city are estimated to consume coffee, given that 25% of population does
 
 select 
 city_name,
 round(population*0.25/1000000,2)as Coffeconsumer_count_in_millions,
 city_rank from city
 order by 2 desc;
 
 
 -- Q2. TOTAL REVENUE FROM COFEE SALES
 -- WHAT IS THE TOTAL REVENUE GENETEATED FROM COFEE SALES ACROSS THE CITIES IN THE LAST QUARTER
 
 SELECT *,
 extract(year from sales_date) as Year ,
 extract(quarter from sales_date) as Qtr
 from sales
 where	extract(year from sales_date) = 2023 
 and extract(quarter from sales_date) = 4;
 
 Select 
 ci.city_name,
 sum(total) as Revenue 
 from Sales as s
 join
 Customers as C
 ON s.customer_id =c.customer_id
 join city as ci
 on ci.city_id = c.city_id
 where 	extract(year from s.sales_date) = 2023 
 and extract(quarter from s.sales_date) = 4
 group by 1
 order by 2 DESC;

select city_name,
sum(total) as Revenue from sales as s
join customers as c 
on s.customer_id = c.customer_id
join city as ci
on c.city_id =ci.city_id
where year(sales_date) =2023
and quarter(sales_date) = 4
group by 1 order by 2 desc;


-- Q3.SALES COUNT FOR EACH PRODUCT
-- HOW MANY UNITS OF EACH COFFEE PRODUCTS AHVE BEEN SOLD?
SELECT PRODUCT_NAME,
COUNT(SALES_ID) AS TOTAL_UNITS 
FROM PRODUCTS AS P
LEFT JOIN SALES AS S
ON P.PRODUCT_ID =S.PRODUCT_ID
GROUP BY 1 ORDER BY 2 DESC;

-- Q4. AVERAGE SALES AMOUNT FOR EACH CITY
-- WHAT IS THE AVG SAles amount per customer in each city

select ci.city_name,
sum(s.total) as revenue,
count(distinct s.customer_id)  as total_custmers,
round((sum(s.total)/count(distinct s.customer_id)),2)
as  Avgsales_percustomer
from sales as s
join customers as c
on s.customer_id =c.customer_id
join city as ci
on c.city_id =ci.city_id
group by 1 order by 2 desc;

-- Q5. CITY POPULATION AND COFFEE CONSUMER
-- PROVIDE LIST OF CITIES ALONG EITH THE POPULATION AND ESTIMATED COFFEE CONSUMER

WITH city_table as  
(SELECT 
  CITY_NAME,
  ROUND((POPULATION*0.25)/1000000,2) AS Total_cofeeconsumers
 FROM CITY),
 CustOmer_table AS
(SELECT
 CI.CITY_NAME,
 COUNT(distinct C.CUSTOMER_ID) AS UNIQUE_cx
 from Sales as S
 join Customers as C 
 On S.customer_id =c.customer_id
 join city as ci 
 on ci.city_id =c.city_id
 group by 1)
 SELECT 
 CITY_TABLE.CITY_NAME,
 CITY_TABLE.Total_cofeeconsumers AS COFFEE_CONSUMERSIN_MILLIONS,
CustOmer_table.UNIQUE_CX
FROM CITY_TABLE
JOIN CUSTOMER_TABLE ON
CITY_TABLE.CITY_NAME = CUSTOMER_TABLE.CITY_NAME
ORDER BY 2 DESC;

-- Q6. TOP SELLING PRODUCTS BY CITY
-- WHAT ARE THE TOP 3 SELLING PRODUCTS IN EACH CITY BASED ON SALES VOLUME

SELECT * FROM
(SELECT 
CI.CITY_NAME,
P.PRODUCT_NAME,
COUNT(S.SALES_ID) AS TOTAL_ORDERS,
DENSE_RANK () OVER( PARTITION BY CI.CITY_NAME ORDER BY COUNT(S.SALES_ID) DESC) AS RANKS
FROM SALES AS S
JOIN PRODUCTS AS P 
ON S.PRODUCT_ID = P.PRODUCT_ID
JOIN CUSTOMERS AS C
ON C.CUSTOMER_ID =S.CUSTOMER_ID
JOIN CITY AS CI
ON C.CITY_ID =CI.CITY_ID
group by 1,2 ) AS T1
-- ORDER BY 1,3 DESC;
WHERE RANKS <=3;



SELECT * FROM
(SELECT CI.CITY_NAME,
P.PRODUCT_NAME,
COUNT(S.SALES_ID),
dense_rank() OVER( PARTITION BY CI.CITY_NAME ORDER BY  COUNT(S.SALES_ID) DESC) AS RANKS
FROM SALES AS S
JOIN PRODUCTS AS P
ON S.PRODUCT_ID = P.PRODUCT_ID
JOIN CUSTOMERS AS C
ON C.CUSTOMER_ID = S.CUSTOMER_ID
JOIN CITY AS CI
ON CI.CITY_ID =C.CITY_ID
GROUP BY 1,2) AS T1
-- ORDER  BY 1,3 DESC;
WHERE RANKS <=3;

-- Q7.CUSTOMERS SEGMENT BY CITY
-- HOW MANY UNIQUE CUSTOMERS ARE THERE IN EACH CITY WHO HAVE purchased coffee products
SELECT ci.city_name, COUNT(DISTINCT S.customer_id) AS unique_customers
FROM sales s
JOIN customers cu 
ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
JOIN city ci ON cu.city_id = ci.city_id
WHERE p.product_name in (1,2,3)  -- Filter for coffee products
GROUP BY ci.city_name;



select ci.city_name, 
count(distinct s.customer_id) as cust_uni,
p.product_name
from sales as s join products as p
on s.product_id =p.product_id
join customers as cu
on cu.customer_id =s.customer_id
LEFT join city as ci
on cu.city_id =ci.city_id
where product_name = "Coffee"
group by 1;

-- Q8. AVERAGE SALES VS RENT
-- FIND EACH CITY AND THEIR AVD SALES PER CUSTOMERS AND AVD RENT PER CUSTOMERS

SELECT 
    ci.city_name,
    CI.ESTIMATED_RENT,
    count(distinct s.customer_id) AS UNIQUE_CU,
round((sum(s.total)/count(distinct s.customer_id)),2) AS AVG_SALES_CUSTOMER,
 round((ci.estimated_rent)/count(distinct s.customer_id),2) AS avg_rent_per_customer
FROM 
    customers cu
JOIN 
    city ci ON cu.city_id = ci.city_id
LEFT JOIN 
    sales s ON cu.customer_id = s.customer_id  -- LEFT JOIN to include customers with no sales
GROUP BY 
    ci.city_name, ci.estimated_rent
    ORDER BY 5 DESC
    ;
    
SELECT CI.CITY_NAME,
CI.ESTIMATED_RENT,
SUM(S.TOTAL) AS REVENUE,
COUNT(DISTINCT S.CUSTOMER_ID) AS UNIQUE_CU,
ROUND(SUM(S.TOTAL)/COUNT(DISTINCT S.CUSTOMER_ID),2) AS AVG_SALES_CUSTOMER,
ROUND(CI.ESTIMATED_RENT/COUNT(DISTINCT S.CUSTOMER_ID),2) AS AVG_RENT_PER_CU
FROM SALES AS S JOIN CUSTOMERS AS CU
ON S.CUSTOMER_ID =CU.CUSTOMER_ID
JOIN CITY AS CI
ON CI.CITY_ID =CU.CITY_ID
GROUP BY 1,2
ORDER BY 6 DESC;

-- Q9. MONTHLY SALES GROWTH
-- SALES GROWTH RATE:CALCUALTE THE PERCENTAGE GROWWTH(OR DECLINE) IN SALES OVER DIFFERENT TIME PERIOD MONTHLY

WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM saleS_date) AS sale_year,
        EXTRACT(MONTH FROM saleS_date) AS sale_month,
        SUM(TOTAL) AS total_sales
    FROM sales
    GROUP BY sale_year, sale_month
),
sales_growth AS (
    SELECT 
        current.sale_year,
        current.sale_month,
        current.total_sales,
        -- Get the total sales from the previous month
        LAG(current.total_sales) OVER (ORDER BY current.sale_year, current.sale_month) AS previous_sales
    FROM monthly_sales current
)
SELECT 
    sale_year,
    sale_month,
    total_sales,
    previous_sales,
    -- Calculate the growth rate percentage
    CASE 
        WHEN previous_sales IS NULL THEN NULL  -- No previous sales data (first month)
        ELSE ROUND(((total_sales - previous_sales) / previous_sales) * 100,2)
    END AS sales_growth_percentage
FROM sales_growth
ORDER BY sale_year, sale_month;

WITH MONTH_WISE AS 
(SELECT CI.CITY_NAME,
       EXTRACT(MONTH FROM SALES_DATE) AS YEARS,
       extract(YEAR FROM SALES_DATE) AS MONTHS,
       SUM(S.TOTAL) AS CR_Total_sales
       from SALES AS S
       JOIN CUSTOMERS AS CU
       ON S.CUSTOMER_ID =CU.CUSTOMER_ID
       JOIN CITY AS CI 
       ON CI.CITY_ID = CU.CITY_ID
       group by 1,2,3
       ORDER BY 1,3,2),
       GROWTH_RATIO AS
	(SELECT CITY_NAME,
       YEARS,
       MONTHS,
       CR_TOTAL_SALES,
       LAG(CR_TOTAL_SALES,1) OVER(PARTITION BY CITY_NAME ) AS PR_TOTAL_SALES
       FROM MONTH_WISE)
       SELECT CITY_NAME,
       YEARS,
       MONTHS,
       CR_TOTAL_SALES,
       PR_TOTAL_SALES,
       ROUND((CR_TOTAL_SALES- PR_TOTAL_SALES)/   PR_TOTAL_SALES*100,2)AS Growth_ratio
       from growth_ratio;
       
       





 
SELECT * from SALES;
                     