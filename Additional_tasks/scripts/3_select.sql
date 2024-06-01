WITH product_markup AS (
  SELECT p.id, p.name, p.supplier_id, (p.sale_price - p.purchase_price) / p.purchase_price AS relative_markup,
    RANK() OVER (PARTITION BY p.supplier_id ORDER BY (p.sale_price - p.purchase_price) / p.purchase_price) AS rnk
  FROM products p
)
SELECT s.name AS supplier, p.relative_markup AS quality_index
FROM product_markup p
JOIN suppliers s ON p.supplier_id = s.id
WHERE p.rnk = 1
ORDER BY p.relative_markup;

SELECT d.name AS department, SUM(i.quantity * p.sale_price) AS total_value
FROM inventory i
JOIN departments d ON i.department_id = d.id
JOIN products p ON i.product_id = p.id
GROUP BY d.id;

SELECT CEIL(COUNT(*) * 0.5 / 8.0) AS cashiers_needed
FROM sales
WHERE sale_date = (SELECT MAX(sale_date) FROM sales);