# 🛒 Retail Sales EDA — MySQL Project

An exploratory data analysis (EDA) project built entirely in **MySQL**, using SQL queries to explore a retail dataset spanning customers, orders, products, and order line items — answering real business questions through joins, aggregations, subqueries, and window functions.

---

## 📌 Project Overview

This project simulates a retail company's sales database and uses SQL to answer common business questions a data analyst would be asked — from simple filters ("customers in Lagos") to more advanced analysis ("top-selling product in each category" and "customers whose sales exceed the average"). It's designed to demonstrate a practical, end-to-end SQL analytics workflow: building a schema, loading data, and progressively working from basic queries to advanced aggregate, join, subquery, and window-function logic.

---

## 🗂 Database Schema

The database consists of four related tables:

| Table | Columns | Description |
|---|---|---|
| `customers` | `customer_id`, `customer_name`, `city`, `segment`, `signup_date` | Customer profile and signup info |
| `products` | `product_id`, `product_name`, `category`, `unit_price` | Product catalog with pricing |
| `orders` | `order_id`, `customer_id`, `order_date` | Order-level records |
| `order_items` | `order_item_id`, `order_id`, `product_id`, `quantity`, `sales_amount` | Line-item detail for each order |

**Relationships:**
- `customers` → `orders` (one customer can place many orders)
- `orders` → `order_items` (one order can contain many items)
- `products` → `order_items` (one product can appear in many order items)

---

## 🔍 Business Questions & Queries

The SQL script is organized progressively, from foundational queries to advanced analysis.

### Basic filtering & sorting

**Customers located in a specific city**
```sql
SELECT *
FROM customers
WHERE city = 'lagos';
```

**Top 10 highest-priced products**
```sql
SELECT *
FROM products
ORDER BY unit_price DESC
LIMIT 10;
```

### Aggregation

**Total sales by product category**
```sql
SELECT category,
       SUM(unit_price) AS total_sales
FROM products
GROUP BY category;
```

**Customer count by segment**
```sql
SELECT segment,
       COUNT(*) AS total_count
FROM customers
GROUP BY segment;
```

**Product/category with the lowest sales**
```sql
SELECT *
FROM products
ORDER BY unit_price ASC
LIMIT 1;
```

### Joins

**Total sales by customer**
```sql
SELECT customer_name,
       sales_amount AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id;
```

**Total sales by city**
```sql
SELECT city,
       SUM(sales_amount) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id;
```

**Total sales by segment**
```sql
SELECT segment,
       SUM(sales_amount) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY segment;
```

**Customers who never placed an order**
```sql
SELECT *
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### Business insight queries

**Which segment generates the most revenue?**
```sql
SELECT segment,
       SUM(sales_amount) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY segment
ORDER BY revenue DESC
LIMIT 1;
```

**Which city contributes the most sales?**
```sql
SELECT city,
       SUM(sales_amount) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY city
ORDER BY total_sales DESC
LIMIT 1;
```


**Category with the highest average order value**
```sql
SELECT category,
       AVG(sales_amount) AS avg_order_value
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY category
ORDER BY avg_order_value DESC
LIMIT 1;
```

**Customers who generated more than ₦100,000 revenue**
```sql
SELECT customer_name,
       SUM(sales_amount) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY customer_name
HAVING revenue > 100000;
```

**Month with the highest sales**
```sql
SELECT MONTHNAME(order_date) AS months,
       SUM(sales_amount) AS sales
FROM orders o
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY MONTHNAME(order_date)
ORDER BY SUM(sales_amount) DESC;
```

**Segment that places the most orders**
```sql
SELECT segment,
       COUNT(order_id) AS orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY segment
ORDER BY orders DESC
LIMIT 1;
```

### Subqueries

**Customers whose sales exceed the average customer sales**
```sql
SELECT customer_name,
       sales_amount AS sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
WHERE sales_amount >
(
    SELECT AVG(sales_amount)
    FROM order_items
);
```

**Products whose revenue exceeds average product revenue**
```sql
SELECT p.product_id,
       product_name,
       (sales_amount) AS revenue
FROM products p
JOIN order_items os
    ON p.product_id = os.product_id
WHERE (sales_amount) >
(
    SELECT AVG(sales_amount)
    FROM order_items
);
```

**Cities whose average sales exceed the overall average**
```sql
SELECT city,
       AVG(sales_amount)
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY city
HAVING AVG(sales_amount) >
( SELECT AVG(sales_amount) FROM order_items );
```

**Customers who made more than 10 purchases**
```sql
SELECT c.customer_id,
       COUNT(order_id)
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(order_id) > 10;
```

### Window functions

**Categories contributing more than 20% of total sales**
```sql
WITH total AS
(
    SELECT category,
           sales_amount,
           ROUND(sales_amount / SUM(sales_amount) OVER (PARTITION BY category) * 100, 2) AS sales_percentage
    FROM products p
    JOIN order_items os
        ON p.product_id = os.product_id
)
SELECT *
FROM total
HAVING sales_percentage > 0.2;
```

**Rank products by revenue**
```sql
SELECT product_name,
       SUM(sales_amount) AS revenue,
       RANK() OVER (ORDER BY SUM(sales_amount)) 
FROM products p
JOIN order_items os
    ON p.product_id = os.product_id
GROUP BY product_name;
```

**Top-selling product in each category**
```sql
SELECT category,
       SUM(sales_amount) AS revenue,
       RANK() OVER (ORDER BY SUM(sales_amount)) AS ranks
FROM products p
JOIN order_items os
    ON p.product_id = os.product_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 1;
```

**Highest-spending customer in each segment**
```sql
SELECT customer_name,
       segment,
       SUM(sales_amount) AS total_sales,
       RANK() OVER (ORDER BY SUM(sales_amount)) AS ranks
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items os
    ON o.order_id = os.order_id
GROUP BY segment;
```

---

## 🛠 Tools Used

- **MySQL 8.0** — schema design, data loading, and querying
- **SQL** — filtering, aggregation, joins, correlated subqueries, CTEs, and window functions

---

## 📁 Repository Contents

```
├── eda_in_mysql.sql   # Full SQL script: schema, data load, and analysis queries
└── README.md          # Project documentation
```

---

## 🚀 How to Use

1. Set up a MySQL 8.0 (or later) instance.
2. Run `eda_in_mysql.sql` in MySQL Workbench or the MySQL CLI to create the tables, load data, and run the analysis queries.
3. Explore, modify, or extend the queries to answer additional business questions.

---

## 📝 Notes

- Some queries (e.g., "orders placed in January 2022") use date literals — double-check date formatting (`YYYY-MM-DD`) when adapting to your own data.
