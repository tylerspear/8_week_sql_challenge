-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	s.customer_id,
    SUM(m.price) as total
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total DESC;

-- 2. How many days has each customer visited the restaurant?
SELECT
	s.customer_id,
	count(DISTINCT s.order_date) as visits
FROM dannys_diner.sales s 
GROUP BY s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH first_sale AS --create a CTE
(
    SELECT customer_id, order_date, product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id --rank each row by customer id and date of purchase
        ORDER BY s.order_date) AS rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM first_sale
WHERE rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.product_id) as purchases
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
LIMIT 1;

SELECT s.customer_id, m.product_name, COUNT(s.product_id) as purchases
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY purchases DESC;


-- 6. Which item was purchased first by the customer after they became a member?
WITH member_purchases AS
(
    SELECT s.customer_id, s.order_date, mem.join_date, m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id --rank each row by customer id and date of purchase
        ORDER BY s.order_date) AS rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
    JOIN dannys_diner.members mem
        ON s.customer_id = mem.customer_id
  	WHERE s.order_date >= mem.join_date
)

SELECT *
FROM member_purchases
WHERE rank = 1;


-- 7. Which item was purchased just before the customer became a member?
WITH member_purchases AS
(
    SELECT s.customer_id, s.order_date, mem.join_date, m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id --rank each row by customer id and date of purchase
        ORDER BY s.order_date DESC) AS rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
    JOIN dannys_diner.members mem
        ON s.customer_id = mem.customer_id
  	WHERE s.order_date < mem.join_date
)

SELECT *
FROM member_purchases
WHERE rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?



