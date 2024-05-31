SELECT * 
FROM products;

SELECT * 
FROM products 
WHERE sale_price > 10000;

SELECT * 
FROM sellers 
ORDER BY last_name;

SELECT name, 
       (sale_price - purchase_price) AS profit 
FROM products;

SELECT product_id, 
       COUNT(*) AS sale_count 
FROM sales 
GROUP BY product_id 
ORDER BY sale_count DESC;

SELECT DISTINCT location 
FROM departments;

SELECT department_id, 
       SUM(quantity) AS total_quantity 
FROM inventory 
GROUP BY department_id;

SELECT s.first_name, 
       s.last_name, 
       COUNT(sa.id) AS sales_count 
FROM sellers s
JOIN sales sa ON s.id = sa.seller_id
GROUP BY s.id, 
         s.first_name, 
         s.last_name
ORDER BY sales_count DESC;
