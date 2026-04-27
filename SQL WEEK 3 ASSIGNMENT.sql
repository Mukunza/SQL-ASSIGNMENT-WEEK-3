
--SQL WEEK 3

-- ADVANCED ANALYTICAL QUESTIONS
-- =====================================================
select * from assignment.customers;
select * from assignment.sales;
select * from assignment.products;
select * from assignment.inventory;

-- 81. Which customers bought products in more than one category?

select c.customer_id, c.first_name, c.last_name, count(distinct p.category) as num_categories
from assignment.customers c
join assignment.sales s on c.customer_id = s.customer_id
join assignment.products p on s.product_id = p.product_id
group by c.customer_id, c.first_name, c.last_name
having count(distinct p.category) > 1;

-- 82. Which customers purchased products within 7 days of registering?

select distinct c.customer_id, c.first_name, c.last_name
from assignment.customers c
join assignment.sales s on c.customer_id = s.customer_id
where s.sale_date between c.registration_date and c.registration_date + INTERVAL '7 days';

-- 83. Which products have lower stock remaining than the average stock quantity?

select product_name, stock_quantity
from assignment.products
where stock_quantity < (select avg(stock_quantity) from assignment.products);

-- 84. Which customers purchased the same product more than once?

select c.customer_id, c.first_name, c.last_name, p.product_name, count(*) as times_purchased
from assignment.customers c
join assignment.sales s on c.customer_id = s.customer_id
join assignment.products p on s.product_id = p.product_id
group by c.customer_id, c.first_name, c.last_name, p.product_name
having count(*) > 1;

-- 85. Which product categories generated the highest total revenue?

select p.category, SUM(s.total_amount) as total_revenue
from assignment.products p
join assignment.sales s on p.product_id = s.product_id
group by p.category
order by total_revenue desc;

-- 86. Which products are among the top 3 most sold products?

select p.product_name, sum(s.quantity_sold) as total_sold
from assignment.products p
join assignment.sales s on p.product_id = s.product_id
group by p.product_name
order by total_sold DESC
limit 3;

-- 87. Which customers purchased the most expensive product?

select distinct c.customer_id, c.first_name, c.last_name
from assignment.customers c
join assignment.sales s on c.customer_id = s.customer_id
join assignment.products p on s.product_id = p.product_id
where p.price = (select max(price) from assignment.products);

-- 88. Which products were purchased by the highest number of unique customers?

select p.product_name, count(distinct s.customer_id) as unique_customers
from assignment.products p
join assignment.sales s on p.product_id = s.product_id
group by p.product_name
order by unique_customers desc;

-- 89. Which customers made purchases above the average sale amount?

SELECT DISTINCT c.customer_id, c.first_name, c.last_name, s.total_amount
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE s.total_amount > (SELECT AVG(total_amount) FROM assignment.sales);

-- 90. Which customers purchased more products than the average quantity purchased per customer?

SELECT c.customer_id, c.first_name, c.last_name, SUM(s.quantity_sold) AS total_qty
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.quantity_sold) > (
SELECT AVG(cust_qty) FROM (
SELECT SUM(quantity_sold) AS cust_qty
FROM assignment.sales
GROUP BY customer_id    ) sub
);

-- ADVANCED WINDOW + ANALYTICAL PROBLEMS

-- 91. Which customers rank in the top 10% of spending?

WITH spending AS (
SELECT customer_id, SUM(total_amount) AS total_spent
FROM assignment.sales
GROUP BY customer_id),
ranked AS (
SELECT *, NTILE(10) OVER (ORDER BY total_spent DESC) AS decile
FROM spending)
SELECT c.customer_id, c.first_name, c.last_name, r.total_spent
FROM ranked r
JOIN assignment.customers c ON r.customer_id = c.customer_id
WHERE r.decile = 1;

-- 92. Which products contribute to the top 50% of total revenue?

WITH product_revenue AS (
SELECT product_id, SUM(total_amount) AS total_rev
FROM assignment.sales
GROUP BY product_id),
revenue_pct AS (
SELECT *,
SUM(total_rev) OVER (ORDER BY total_rev DESC) AS running_total,
SUM(total_rev) OVER () AS grand_total
FROM product_revenue)
SELECT p.product_name, rp.total_rev
FROM revenue_pct rp
JOIN assignment.products p ON rp.product_id = p.product_id
WHERE rp.running_total <= rp.grand_total * 0.5;

-- 93. Which customers made purchases in consecutive months?

WITH monthly_purchases AS (
SELECT DISTINCT customer_id,
DATE_TRUNC('month', sale_date) AS sale_month
FROM assignment.sales),
with_lag AS (
SELECT *,
LAG(sale_month) OVER (PARTITION BY customer_id ORDER BY sale_month) AS prev_month
FROM monthly_purchases)
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM with_lag wl
JOIN assignment.customers c ON wl.customer_id = c.customer_id
WHERE wl.sale_month = wl.prev_month + INTERVAL '1 month';

-- 94. Which products experienced the largest difference between stock quantity and total quantity sold?

SELECT p.product_name,
       p.stock_quantity,
       COALESCE(SUM(s.quantity_sold), 0) AS total_sold,
       p.stock_quantity - COALESCE(SUM(s.quantity_sold), 0) AS stock_difference
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_name, p.stock_quantity
ORDER BY stock_difference DESC;

-- 95. Which customers have spending above the average spending of their membership tier?

WITH tier_avg AS (SELECT c.membership_status, AVG(s.total_amount) AS avg_spent
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.membership_status),
customer_totals AS (SELECT c.customer_id, c.first_name, c.last_name,
c.membership_status, SUM(s.total_amount) AS total_spent
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status)
SELECT ct.*
FROM customer_totals ct
JOIN tier_avg ta ON ct.membership_status = ta.membership_status
WHERE ct.total_spent > ta.avg_spent;

-- 96. Which products have higher sales than the average sales within their category?

WITH category_avg AS (
SELECT p.category, AVG(s.total_amount) AS avg_sales
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.category),
product_sales AS (
SELECT p.product_id, p.product_name, p.category, SUM(s.total_amount) AS total_sales
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category)
SELECT ps.*
FROM product_sales ps
JOIN category_avg ca ON ps.category = ca.category
WHERE ps.total_sales > ca.avg_sales;

-- 97. Which customer made the largest single purchase relative to their total spending?

WITH customer_totals AS (
SELECT customer_id, SUM(total_amount) AS total_spent
FROM assignment.sales
GROUP BY customer_id),
single_max AS (
SELECT customer_id, MAX(total_amount) AS max_single_purchase
FROM assignment.sales
GROUP BY customer_id)
SELECT c.customer_id, c.first_name, c.last_name,
       sm.max_single_purchase,
       ct.total_spent,
       ROUND((sm.max_single_purchase / ct.total_spent) * 100, 2) AS pct_of_total
FROM single_max sm
JOIN customer_totals ct ON sm.customer_id = ct.customer_id
JOIN assignment.customers c ON sm.customer_id = c.customer_id
ORDER BY pct_of_total DESC
LIMIT 1;

-- 98. Which products rank among the top 3 most sold products within each category?

WITH category_sales AS (
SELECT p.product_id, p.product_name, p.category, SUM(s.quantity_sold) AS total_qty
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category),
ranked AS (
SELECT *,
RANK() OVER (PARTITION BY category ORDER BY total_qty DESC) AS rank_in_category
FROM category_sales)
SELECT product_name, category, total_qty, rank_in_category
FROM ranked
WHERE rank_in_category <= 3;

-- 99. Which customers are tied for the highest total spending?

WITH customer_totals AS (
SELECT customer_id, SUM(total_amount) AS total_spent
FROM assignment.sales
GROUP BY customer_id)
SELECT c.customer_id, c.first_name, c.last_name, ct.total_spent
FROM customer_totals ct
JOIN assignment.customers c ON ct.customer_id = c.customer_id
WHERE ct.total_spent = (SELECT MAX(total_spent) FROM customer_totals);


-- 100. Which products generated sales every year present in the dataset?

WITH product_years AS (
SELECT DISTINCT product_id, EXTRACT(YEAR FROM sale_date) AS sale_year
FROM assignment.sales),
all_years AS (
SELECT DISTINCT EXTRACT(YEAR FROM sale_date) AS sale_year
FROM assignment.sales),
year_count AS (
SELECT COUNT(*) AS total_years FROM all_years),
product_year_count AS (
SELECT product_id, COUNT(*) AS years_with_sales
FROM product_years
GROUP BY product_id)
SELECT p.product_name
FROM product_year_count pyc
JOIN assignment.products p ON pyc.product_id = p.product_id
JOIN year_count yc ON pyc.years_with_sales = yc.total_years;

-- 101. Update the products table to assign a price_category as Expensive (price > 1000), Moderate (price between 500 and 1000), or Affordable (price < 500) using CASE WHEN

ALTER TABLE assignment.products ADD COLUMN IF NOT EXISTS price_category VARCHAR(20);

UPDATE assignment.products
SET price_category = CASE
WHEN price > 1000 THEN 'Expensive'
WHEN price BETWEEN 500 AND 1000 THEN 'Moderate'
ELSE 'Affordable'
END;

-- 102. Update the customers table to assign a customer_level based on total spending as VIP (>20000), Regular (10000–20000), or New (<10000) using CASE WHEN

ALTER TABLE assignment.customers ADD COLUMN IF NOT EXISTS customer_level VARCHAR(10);

UPDATE assignment.customers c
SET customer_level = CASE
WHEN total_spent > 20000 THEN 'VIP'
WHEN total_spent BETWEEN 10000 AND 20000 THEN 'Regular'
ELSE 'New'
END
FROM (SELECT customer_id, SUM(total_amount) AS total_spent
FROM assignment.sales
GROUP BY customer_id) s
WHERE c.customer_id = s.customer_id;

-- 103. Update the products table to assign a stock_status as Low Stock or Sufficient Stock based on stock_quantity using CASE WHEN

ALTER TABLE assignment.products ADD COLUMN IF NOT EXISTS stock_status VARCHAR(20);

UPDATE assignment.products
SET stock_status = CASE
WHEN stock_quantity < 50 THEN 'Low Stock'
ELSE 'Sufficient Stock'
END;

-- 104. Display each customer’s registration year from the registration_date

SELECT customer_id, first_name, last_name,
EXTRACT(YEAR FROM registration_date) AS registration_year
FROM assignment.customers;

-- 105. Count how many customers registered in each year

SELECT EXTRACT(YEAR FROM registration_date) AS registration_year,
COUNT(*) AS customer_count
FROM assignment.customers
GROUP BY registration_year
ORDER BY registration_year;

-- 106. Find the total sales amount for each month

SELECT EXTRACT(YEAR FROM sale_date) AS year,
EXTRACT(MONTH FROM sale_date) AS month,
SUM(total_amount) AS monthly_total
FROM assignment.sales
GROUP BY year, month
ORDER BY year, month;


-- 107. Show all sales made in the year 2023
SELECT * FROM assignment.sales
WHERE EXTRACT(YEAR FROM sale_date) = 2023;


-- 108. Find the total sales amount for each year

SELECT EXTRACT(YEAR FROM sale_date) AS sale_year,
SUM(total_amount) AS yearly_total
FROM assignment.sales
GROUP BY sale_year
ORDER BY sale_year;

-- 109. Calculate the number of days each customer has been registered (from registration_date to current date)

SELECT customer_id, first_name, last_name,registration_date,
CURRENT_DATE - registration_date AS days_registered
FROM assignment.customers;

-- 110. Display each sale and extract the year and month from the sale date

SELECT sale_id, sale_date,
EXTRACT(YEAR FROM sale_date) AS sale_year,
EXTRACT(MONTH FROM sale_date) AS sale_month
FROM assignment.sales;

-- 111. Display each customer’s email and replace null values with 'No Email Provided' using COALESCE

SELECT customer_id, first_name, last_name,
COALESCE(email, 'No Email Provided') AS email
FROM assignment.customers;


-- 112. Find customers who do not have an email address

SELECT customer_id, first_name, last_name
FROM assignment.customers
WHERE email IS NULL;

-- 113. Find products that have never been sold using a subquery

SELECT product_name
FROM assignment.products
WHERE product_id NOT IN (
SELECT DISTINCT product_id FROM assignment.sales);

-- 114. Find customers who have not made any purchases using a subquery

SELECT customer_id, first_name, last_name
FROM assignment.customers
WHERE customer_id NOT IN (
SELECT DISTINCT customer_id FROM assignment.sales);

-- 115. Update the products table to assign a price_category (Premium, Standard, Budget) based on price using CASE WHEN

UPDATE assignment.products
SET price_category = CASE
WHEN price > 1000 THEN 'Premium'
WHEN price BETWEEN 500 AND 1000 THEN 'Standard'
ELSE 'Budget'
END;

-- 116. Create a PostgreSQL function/procedure that takes a minimum revenue as input and returns all products whose total sales exceed that value
CREATE OR REPLACE FUNCTION assignment.get_products_above_revenue(min_revenue DECIMAL)
RETURNS TABLE (product_name VARCHAR, total_revenue DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT p.product_name, SUM(s.total_amount)
    FROM assignment.products p
    JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_name
    HAVING SUM(s.total_amount) > min_revenue;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM assignment.get_products_above_revenue(500);


-- 117. Create a PostgreSQL function/procedure that takes a customer_id as input and returns the total amount spent by that customer

CREATE OR REPLACE FUNCTION assignment.get_customer_total(cust_id INT)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT SUM(total_amount) INTO total
    FROM assignment.sales
    WHERE customer_id = cust_id;
    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

SELECT assignment.get_customer_total(1);

-- 118. Create a PostgreSQL function/procedure that takes a start_date and end_date as input and returns the number of orders made within that date range

CREATE OR REPLACE FUNCTION assignment.count_orders_in_range(start_date DATE, end_date DATE)
RETURNS INT AS $$
DECLARE
    order_count INT;
BEGIN
    SELECT COUNT(*) INTO order_count
    FROM assignment.sales
    WHERE sale_date BETWEEN start_date AND end_date;
    RETURN order_count;
END;
$$ LANGUAGE plpgsql;

SELECT assignment.count_orders_in_range('2023-01-01', '2023-12-31');

-- 119. Create a PostgreSQL stored procedure that inserts a new record into the sales table 

CREATE OR REPLACE PROCEDURE assignment.insert_new_sale(
    p_sale_id INT,
    p_customer_id INT,
    p_product_id INT,
    p_quantity_sold INT,
    p_sale_date DATE,
    p_total_amount DECIMAL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO assignment.sales (sale_id, customer_id, product_id, quantity_sold, sale_date, total_amount)
    VALUES (p_sale_id, p_customer_id, p_product_id, p_quantity_sold, p_sale_date, p_total_amount);
    RAISE NOTICE 'Sale inserted successfully.';
END;
$$;

CALL assignment.insert_new_sale(16, 1, 2, 1, '2024-06-01', 799.99);

-- 120. Create an index on the product_id column in the sales table to improve join performance

CREATE INDEX IF NOT EXISTS idx_sales_product_id ON assignment.sales(product_id);

-- 121. Create an index on the registration_date column in the customers table to improve filtering by date

CREATE INDEX IF NOT EXISTS idx_customers_registration_date ON assignment.customers(registration_date);

-- 122. Write a transaction that inserts a new sale using sale_id, customer_id, product_id, quantity_sold, sale_date, and total_amount, then updates the corresponding product stock_quantity, ensuring both operations succeed or fail together
BEGIN;

INSERT INTO assignment.sales (sale_id, customer_id, product_id, quantity_sold, sale_date, total_amount)
VALUES (17, 5, 3, 1, CURRENT_DATE, 499.99);

UPDATE assignment.inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 3;

COMMIT;

-- 123. Write a transaction that updates a customer’s email and rolls back the change if the email is invalid
BEGIN;

UPDATE assignment.customers
SET email = 'newemail@example.com'
WHERE customer_id = 1;

-- Validate: rollback if email doesn't contain '@'
DO $$
BEGIN
    IF (SELECT email FROM assignment.customers WHERE customer_id = 1) NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;
END;
$$;

COMMIT;

-- 124. Create a view that shows total revenue per product

CREATE OR REPLACE VIEW assignment.product_revenue_view AS
SELECT p.product_id, p.product_name, SUM(s.total_amount) AS total_revenue
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;

SELECT * FROM assignment.product_revenue_view;

-- 125. Create a view that shows each customer and their total spending

CREATE OR REPLACE VIEW assignment.customer_spending_view AS
SELECT c.customer_id, c.first_name, c.last_name, SUM(s.total_amount) AS total_spent
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

SELECT * FROM assignment.customer_spending_view;

-- 126. Use UNION to combine a list of all customer first names and product names into a single column

SELECT first_name AS name, 'Customer' AS source FROM assignment.customers
UNION
SELECT product_name, 'Product' FROM assignment.products;

-- 127. Use INTERSECT to find values that appear in both a list of customer IDs and a list of customer IDs who made purchases

SELECT customer_id FROM assignment.customers
INTERSECT
SELECT customer_id FROM assignment.sales;

-- 128. Perform an anti-join to find products that have never been sold using LEFT JOIN

SELECT p.product_name
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL;

-- 129. Use NOT EXISTS to find customers who have not made any purchases

SELECT c.customer_id, c.first_name, c.last_name
FROM assignment.customers c
WHERE NOT EXISTS (
SELECT 1 FROM assignment.sales s
WHERE s.customer_id = c.customer_id);

-- 130. Cast the price column to an integer and display it alongside the original price

SELECT product_name, price AS original_price, CAST(price AS INT) AS price_as_integer
FROM assignment.products;

-- 131. Convert registration_date to text format and display it in 'YYYY-MM' format

SELECT customer_id, first_name, TO_CHAR(registration_date, 'YYYY-MM') AS registration_year_month
FROM assignment.customers;

-- 132. The following query returns an error due to improper GROUP BY usage. Identify and fix the issue

SELECT s.product_id, p.product_name, SUM(s.total_amount) AS total_amount
FROM assignment.sales s
JOIN assignment.products p ON s.product_id = p.product_id
GROUP BY s.product_id, p.product_name;

-- 133. The following query incorrectly filters aggregated results using WHERE. Identify and correct it

SELECT product_id, SUM(total_amount) AS total_amount
FROM assignment.sales
GROUP BY product_id
HAVING SUM(total_amount) > 1000;

-- 134. The following query returns incorrect results because it uses the wrong join condition. Identify and fix it

SELECT *FROM assignment.sales s
JOIN assignment.products p
ON s.customer_id = p.product_id;

-- 135. Replace NULL email values with 'No Email Provided' using COALESCE if any

SELECT customer_id, COALESCE(email, 'No Email Provided') AS email
FROM assignment.customers;

-- 136. Trim any leading or trailing spaces from customer first names if any

SELECT customer_id, TRIM(first_name) AS first_name_trimmed
FROM assignment.customers;

-- 137. Convert all customer emails to lowercase if any

SELECT customer_id, LOWER(email) AS email_lowercase
FROM assignment.customers;

-- 138. Replace empty strings in phone numbers with NULL if any

UPDATE assignment.customers
SET phone_number = NULL
WHERE TRIM(phone_number) = '';

-- 139. Extract the year from registration_date and handle any NULL dates gracefully if any

SELECT customer_id, first_name, registration_date,
CASE
WHEN registration_date IS NULL THEN 'No Date'
ELSE CAST(EXTRACT(YEAR FROM registration_date) AS TEXT)
END AS registration_year
FROM assignment.customers;


