# НИЯУ МИФИ. Дополнительные задания к лабораторным 2-4. Журбенко Василий, Б21-525. 2024

## SQL сценарии
[Новые запросы](./scripts/3_select.sql)


## 1. Индекс качества поставщика
> 1. Магазин смыслит в качественных изделиях, и ставит более высокую наценку на более качественные изделия. Пусть качество изделия определяется относительной величиной наценки.
Выведите для каждого поставщика "индекс качества поставщика". Он определяется относительной наценкой магазина на самое неоценённое своё изделие. Т.е., поставщик предлагает два товара, и мы продаём их с наценками 0.2 и 0.35, то индекс качества поставщика составляет 0.2;

#### SQL запрос
```sql
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
```

 Вычисляем относительную наценку для каждого продукта, ранжируем продукты по поставщику и относительной наценке, выбираем продукт с минимальной наценкой для каждого поставщика, эта наценка становится индексом качества.

<details>
<summary>Результат</summary>

| supplier              | quality_index |
|------------------------|---------------|
| ООО "Золотая россыпь"  | 0.5           |
| АО "Бриллиант Плюс"    | 0.5           |
| ООО "Драгоценные камни"| 0.571428571429|
| ИП "Серебряный ветер"  | 0.6           |

</details>

## 2. Суммарная стоимость ценностей в каждом отделе
> 2. Для каждого отдела посчитайте суммарную стоимость ценностей, которые в нём хранятся;

#### SQL запрос
```sql
SELECT d.name AS department, SUM(i.quantity * p.sale_price) AS total_value
FROM inventory i
JOIN departments d ON i.department_id = d.id
JOIN products p ON i.product_id = p.id
GROUP BY d.id;
```

Объединяем таблицы inventory, departments и products, чтобы получить количество и цену продажи для каждого продукта в каждом отделе. Суммируем количество, умноженное на цену продажи, для каждого отдела.

<details>
<summary>Результат</summary>

| department | total_value |
|------------|--------------|
| Центральный| 2055000.0   |
| Северный   | 1485000.0   |
| Южный      | 1760000.0   |
| Восточный  | 1700000.0   |

</details>

# 3. Количество кассиров
> 3. Предположим, что одна операция продажи занимает 30 минут времени кассира. Кассир работает 8 часов в день. Все продажи в БД были выполнены в течение одного дня. Сколько кассиров нужно магазину?

[Добавляем записи продаж за последний день](./scripts/2-2_more_sales.sql)

#### SQL запрос
```sql
SELECT CEIL(COUNT(*) * 0.5 / 8.0) AS cashiers_needed
FROM sales
WHERE sale_date = (SELECT MAX(sale_date) FROM sales); -- вычисляем для последней даты
```

<details>
<summary>Результат</summary>

| cashiers_needed |
|-----------------|
| 5                |

</details>