-- 1. Полная выборка всех товаров
SELECT * FROM products;

-- 2. Условная выборка товаров с ценой продажи более 10000
SELECT * FROM products WHERE sale_price > 10000;

-- 3. Упорядоченная выборка всех продавцов по фамилии в порядке возрастания
SELECT * FROM sellers ORDER BY last_name;

-- 4. Выборка товаров с вычислением разницы между ценой продажи и ценой закупки
SELECT name, (sale_price - purchase_price) AS profit FROM products;

-- 5. Подсчёт количества продаж для каждого товара и упорядочивание по количеству в убывающем порядке
SELECT product_id, COUNT(*) AS sale_count FROM sales GROUP BY product_id ORDER BY sale_count DESC;

-- 6. Выборка уникальных локаций отделов
SELECT DISTINCT location FROM departments;

-- 7. Подсчёт общего количества товаров в каждом отделе
SELECT department_id, SUM(quantity) AS total_quantity FROM inventory GROUP BY department_id;

-- 8. Выборка продавцов и количества их продаж, упорядоченная по количеству продаж в порядке убывания
SELECT s.first_name, s.last_name, COUNT(sa.id) AS sales_count FROM sellers s
JOIN sales sa ON s.id = sa.seller_id
GROUP BY s.id, s.first_name, s.last_name
ORDER BY sales_count DESC;
