CREATE TABLE customers(
customer_id  VARCHAR(20), 
 customer_name  VARCHAR(30),
 city VARCHAR(20),
 segment VARCHAR(20),
signup_date DATE
)
;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE products(
product_id	VARCHAR(20),
product_name VARCHAR(30),
category VARCHAR(20),
unit_price NUMERIC
)
;


CREATE TABLE orders(
order_id VARCHAR(20),
customer_id	VARCHAR(20),
order_date	DATE
)
;


CREATE TABLE order_items(
order_item_id VARCHAR(20),
order_id	VARCHAR(20),
product_id	VARCHAR(20),
quantity	INT,
sales_amount	NUMERIC
)
;


SELECT*
FROM customers;


SELECT*
FROM orders;


SELECT*
FROM products;

SELECT*
FROM order_items;

-- show all customers from lagos
SELECT*
FROM customers
where city = 'lagos'
;

-- products with price above 5000
select*
from products
where unit_price > 5000
;

-- orders placed in january 2022
select*
from orders
where order_date between '2022=01=01' and '2022-01-31'
;

-- top 10 highest priced products 
select*
from products 
order by unit_price desc
limit 10;


-- total sales generated

select sum(sales_amount) as total_sales
from order_items;

-- number of orders placed
select count(*)
from orders;

-- average order values
select avg(sales_amount)
from order_items;

-- total sales by category
select category,
sum(unit_price) as total_sales
from products
group by category
;


-- number of customers in each segment
select segment,
count(*) as total_count
from customers
group by segment
;

-- Product category with the lowest sales.
select *
from products
order by unit_price asc
limit 1;

-- show customer names and their orders
select*
from customers c
inner join orders o
	on c.customer_id = o.customer_id
    ;
-- Show products purchased by each customer. 

select o.customer_id,
os.product_id,
p.category
from orders o 
 join order_items os
	on o.order_id = os.order_id
 join products p
	on p.product_id = os.product_id
    ;

-- Total sales by customer. 
select customer_name,
sales_amount as total_sales
from customers c
join orders o
	on c.customer_id = o.customer_id
join order_items os
	on o.order_id = os.order_id;
    
-- Total sales by city. 
select city,
sum(sales_amount) as total_sales
from customers c
join orders o
	on c.customer_id = o.customer_id
join order_items os
	on o.order_id = os.order_id
    ;
    

-- Total sales by segment. 
SELECT 
segment,
sum(sales_amount) as total_sales
FROM customers c 
JOIN orders o 
	ON c.customer_id = o.customer_id
JOIN order_items os
		ON o.order_id = os.order_id
group by segment
;

-- Customers who never placed an order. 

SELECT*
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id 
WHERE o.order_id IS NULL
;   

-- Which segment generates the most revenue?     
SELECT 
segment,
sum(sales_amount) as revenue
FROM customers c 
JOIN orders o 
	ON c.customer_id = o.customer_id
JOIN order_items os
		ON o.order_id = os.order_id
group by segment
ORDER BY revenue DESC
LIMIT 1;

-- Which city contributes the most sales? 

SELECT 
city,
sum(sales_amount) as total_sales
FROM customers c 
JOIN orders o 
	ON c.customer_id = o.customer_id
JOIN order_items os
		ON o.order_id = os.order_id
group by city
order by total_sales desc
limit 1
;

-- What are the top 5 products by revenue? 
SELECT 
product_name,
sum(sales_amount) as Revenue
FROM products p
JOIN order_items os
	ON p.product_id = os.product_id
group by product_name
order by revenue desc
limit 5;

-- Which category has the highest average order value? 
SELECT 
category,
avg(sales_amount) as avg_order_value
FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id
group by category
order by avg_order_value desc
limit 1;

-- 	Which customers generated more than ₦100,000 revenue? 

SELECT 
customer_name,
sum(sales_amount) as revenue
FROM customers c 
JOIN orders o 
	ON c.customer_id = o.customer_id
JOIN order_items os
		ON o.order_id = os.order_id
group by customer_name
having revenue > 100000
;

-- 	Which month recorded the highest sales? 
select
monthname(order_date) as months,
sum(sales_amount) as sales
from orders o
join order_items os
	ON o.order_id = os.order_id
group by monthname(order_date) 
order by sum(sales_amount) desc;

-- 	Which segment places the most orders? 
select
segment,
count(order_id) as orders
from customers c
join orders o
	on c.customer_id = o.customer_id
group by segment
order by orders desc
limit 1;

-- 	Customers whose sales exceed the average customer sales. 

SELECT 
customer_name,
sales_amount AS sales
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items os
		ON o.order_id = os.order_id
WHERE sales_amount >
(
SELECT avg(sales_amount) 
FROM order_items
)
;

-- 	Products whose revenue exceeds average product revenue. 
SELECT 
p.product_id,
product_name,
(sales_amount) AS revenue
FROM products p
JOIN order_items os
	ON p.product_id = os.product_id
WHERE (quantity*sales_amount) >
(
SELECT avg(quantity*sales_amount)
FROM order_items
);

-- 	Cities whose sales exceed overall average city sales. 
SELECT 
city,
avg(sales_amount)
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items os
	ON o.order_id = os.order_id
group by city
having avg(sales_amount) >
( select avg(sales_amount) from order_items)
;

-- 	Customers who made more than 10 purchases. 
SELECT 
c.customer_id,
count(order_id)
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
group by c.customer_id
having count(order_id) > 10;

-- 	Categories contributing more than 20% of total sales

with total as
(select
category,
sales_amount, 
round(sales_amount/sum(sales_amount)over(partition by category)*100,2) as sales_percentage
from products p
join order_items os
	on p.product_id = os.product_id
)
select * 
from total
having sales_percentage > 0.2
;

-- 	Rank products by revenue. 
select product_name,
sum(sales_amount) as revenue,
rank() over(order by sum(sales_amount))
from products p
join order_items os
	on p.product_id = os.product_id
group by product_name;

-- 	Find the top-selling product in each category. 
 select 
category,
sum(sales_amount) as revenue,
rank() over(order by sum(sales_amount)) as ranks
from products p
join order_items os
	on p.product_id = os.product_id
group by category
order by revenue desc
limit 1;

-- 	Find the highest-spending customer in each segment. 
select 
customer_name,
segment,
sum(sales_amount) as total_sales,
rank() over(order by sum(sales_amount)) as ranks
from customers c
join orders o
	on c.customer_id = o.customer_id
join order_items os
	on o.order_id = os.order_id
group by segment