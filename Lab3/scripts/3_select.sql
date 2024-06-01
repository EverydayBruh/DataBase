SELECT c.first_name, c.last_name
FROM customers c
WHERE c.discount > (SELECT 5.0);

SELECT s.first_name AS seller_name, s.last_name AS seller_last_name,
       c.first_name AS customer_name, c.last_name AS customer_last_name,
       sa.sale_date, sa.quantity, sa.discount
FROM sales sa
JOIN sellers s ON sa.seller_id = s.id
JOIN customers c ON sa.customer_id = c.id;

SELECT p.name AS product_name, s.name AS supplier_name, s.contact_info
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.id;

SELECT s.first_name, s.last_name, COUNT(sa.id) AS sales_count,
       RANK() OVER (ORDER BY COUNT(sa.id) DESC) AS sales_rank
FROM sellers s
LEFT JOIN sales sa ON s.id = sa.seller_id
GROUP BY s.id
ORDER BY sales_rank;

SELECT sale_date,
       SUM(quantity) OVER (ORDER BY sale_date) AS running_total
FROM sales;

WITH product_totals AS (
  SELECT p.id, p.name, SUM(i.quantity) AS total_quantity
  FROM products p
  LEFT JOIN inventory i ON p.id = i.product_id
  GROUP BY p.id
)
SELECT name, total_quantity
FROM product_totals
ORDER BY total_quantity DESC;

WITH sales_last_month AS (
  SELECT p.name, SUM(s.quantity) AS total_quantity, SUM(s.quantity * p.sale_price * (1 - COALESCE(s.discount, 0))) AS total_revenue
  FROM sales s
  JOIN products p ON s.product_id = p.id
  WHERE s.sale_date >= DATE('now', '-1 month')
  GROUP BY p.name
)
SELECT name, total_quantity, total_revenue
FROM sales_last_month
ORDER BY total_revenue DESC;

WITH product_markup AS (
  SELECT p.id, p.name, p.supplier_id, (p.sale_price - p.purchase_price) AS markup,
    RANK() OVER (PARTITION BY p.supplier_id ORDER BY (p.sale_price - p.purchase_price) DESC) AS rnk
  FROM products p
)
SELECT p.name AS product, s.name AS supplier, p.markup
FROM product_markup p
JOIN suppliers s ON p.supplier_id = s.id
WHERE p.rnk = 1
ORDER BY p.markup DESC;