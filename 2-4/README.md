# НИЯУ МИФИ. Лабораторная работа №2-4

## Индексы

### Журбенко Василий, Б21-525  
### 2024


## На защиту
**Попробуйте хотя бы один индекс, не являющийся B+tree.**

Для эффективного поиска по названию добавим столбец tsvector и индексирование GIN (оптимален для индексации полей, содержащих множество значений - массивов или текстовых полей)
```sql
ALTER TABLE products ADD COLUMN name_tsv tsvector GENERATED ALWAYS AS (to_tsvector('russian', name)) STORED;
CREATE INDEX idx_products_name_tsv ON products USING gin(name_tsv);
```

Результат EXPLAIN ANALYZE подтверждает, что новый индекс используется.
```sql
jewelry_store=# EXPLAIN ANALYZE
jewelry_store-# SELECT *       
jewelry_store-# FROM products  
jewelry_store-# WHERE name_tsv @@ plainto_tsquery('russian', 'серебряное кольцо');
                                                           QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on products  (cost=12.00..16.01 rows=1 width=143) (actual time=0.701..1.360 rows=712 loops=1)
   Recheck Cond: (name_tsv @@ '''серебрян'' & ''кольц'''::tsquery)
   Heap Blocks: exact=264
   ->  Bitmap Index Scan on idx_products_name_tsv  (cost=0.00..12.00 rows=1 width=0) (actual time=0.629..0.630 rows=712 loops=1) 
         Index Cond: (name_tsv @@ '''серебрян'' & ''кольц'''::tsquery)
 Planning Time: 0.328 ms
 Execution Time: 1.456 ms
(7 rows)
```


# Схема данных
### Таблица `departments`
- `id` (Primary Key) - уникальный идентификатор отдела
- `name` - название отдела
- `location` - локация отдела

### Таблица `products`
- `id` (Primary Key) - уникальный идентификатор товара
- `name` - название товара
- `description` - описание товара
- `purchase_price` - цена закупки
- `sale_price` - цена продажи
- `supplier_id` (Foreign Key) - идентификатор поставщика

### Таблица `suppliers`
- `id` (Primary Key) - уникальный идентификатор поставщика
- `name` - название поставщика
- `contact_info` - контактная информация

### Таблица `sales`
- `id` (Primary Key) - уникальный идентификатор продажи
- `product_id` (Foreign Key) - идентификатор товара
- `seller_id` (Foreign Key) - идентификатор продавца
- `sale_date` - дата продажи
- `quantity` - количество проданного товара
- `discount` - скидка

### Таблица `sellers`
- `id` (Primary Key) - уникальный идентификатор продавца
- `first_name` - имя продавца
- `last_name` - фамилия продавца
- `department_id` (Foreign Key) - идентификатор отдела

### Таблица `customers`
- `id` (Primary Key) - уникальный идентификатор покупателя
- `first_name` - имя покупателя
- `last_name` - фамилия покупателя
- `discount_card` - наличие дисконтной карты (да/нет)
- `discount` - скидка

### Таблица `inventory`
- `id` (Primary Key) - уникальный идентификатор записи инвентаря
- `product_id` (Foreign Key) - идентификатор товара
- `department_id` (Foreign Key) - идентификатор отдела
- `quantity` - количество товара в отделе
![](assets/mermaid-diagram-2025-01-05-193634.png)

# Добавленние индексов
```sql
-- 1. Индекс для поиска товаров по названию
-- Частый запрос от клиентов и продавцов при поиске конкретных украшений
CREATE INDEX idx_products_name ON products USING btree (name);

-- 2. Составной индекс для анализа продаж по датам
-- Важен для отчетов по продажам, анализа выручки
CREATE INDEX idx_sales_date_product ON sales USING btree (sale_date, product_id);

-- 3. Составной индекс для проверки наличия товаров
-- Критически важен для быстрой проверки наличия товара в конкретном отделе
CREATE INDEX idx_inventory_prod_dept ON inventory USING btree (product_id, department_id);

-- 4. Индекс для анализа работы продавцов
-- Необходим для отчетов по эффективности продавцов
CREATE INDEX idx_sales_seller_date ON sales USING btree (seller_id, sale_date);

-- 5. Индекс для поиска по ценовому диапазону
-- Частый запрос при подборе украшений по бюджету клиента
CREATE INDEX idx_products_price ON products USING btree (sale_price);

-- 6. Индекс для поиска клиентов с картами лояльности
-- Важен для быстрого поиска постоянных клиентов и применения скидок
CREATE INDEX idx_customers_discount ON customers USING btree (discount_card) WHERE discount_card = true;
```

# Генерация данных
[Скрипт генерации](scripts/5_large_insert.sql)

# Результаты тестирования индексов

## Запрос выручки по дням за последние 30 дней
```sql
EXPLAIN ANALYZE
SELECT 
    s.sale_date,
    SUM(s.quantity * p.sale_price * (1 - COALESCE(s.discount, 0)/100)) as revenue
FROM sales s
JOIN products p ON p.id = s.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY s.sale_date
ORDER BY s.sale_date;
```
<details>
<summary>QUERY PLAN</summary>

```
Sort  (cost=136.39..137.25 rows=343 width=36) (actual time=2.005..2.010 rows=31 loops=1)
  Sort Key: s.sale_date
  Sort Method: quicksort  Memory: 26kB
  ->  HashAggregate  (cost=117.66..121.95 rows=343 width=36) (actual time=1.971..1.988 rows=31 loops=1)
        Group Key: s.sale_date
        Batches: 1  Memory Usage: 45kB
        ->  Hash Join  (cost=15.96..103.00 rows=838 width=43) (actual time=0.165..0.967 rows=831 loops=1)
              Hash Cond: (s.product_id = p.id)
              ->  Bitmap Heap Scan on sales s  (cost=14.78..98.45 rows=838 width=15) (actual time=0.120..0.528 rows=831 loops=1)
                    Recheck Cond: (sale_date >= (CURRENT_DATE - '30 days'::interval))
                    Heap Blocks: exact=69
                    ->  Bitmap Index Scan on idx_sales_date_product  (cost=0.00..14.58 rows=838 width=0) (actual time=0.099..0.099 rows=831 loops=1)
                          Index Cond: (sale_date >= (CURRENT_DATE - '30 days'::interval))
              ->  Hash  (cost=1.08..1.08 rows=8 width=36) (actual time=0.027..0.028 rows=8 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    ->  Seq Scan on products p  (cost=0.00..1.08 rows=8 width=36) (actual time=0.008..0.010 rows=8 loops=1)
Planning Time: 3.354 ms
Execution Time: 2.128 ms
```
</details>

**Комментарий:**
- Используется составной индекс `idx_sales_date_product` (тип: btree), который покрывает поля `sale_date` и `product_id`.
- Индекс оптимально применяется для фильтрации строк по дате (`sale_date >= CURRENT_DATE - INTERVAL '30 days'`).
- Bitmap Index Scan дополнительно ускоряет выборку строк, соответствующих указанным условиям, до выполнения хэш-соединения.
- Итоговая агрегация и сортировка выполняются эффективно за счет компактных структур данных.
- Время выполнения: 2.128 мс.

## Анализ продаж по продавцам за 90 дней
```sql
EXPLAIN ANALYZE
SELECT 
    s.seller_id,
    sel.first_name,
    sel.last_name,
    COUNT(*) as sales_count,
    SUM(s.quantity * p.sale_price * (1 - COALESCE(s.discount, 0)/100)) as total_revenue
FROM sales s
JOIN sellers sel ON sel.id = s.seller_id
JOIN products p ON p.id = s.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY s.seller_id, sel.first_name, sel.last_name
ORDER BY total_revenue DESC;
```
<details>
<summary>QUERY PLAN</summary>

```
Sort  (cost=706.75..710.75 rows=1600 width=108) (actual time=6.444..6.448 rows=8 loops=1)
  Sort Key: (sum((((s.quantity)::numeric * p.sale_price) * ('1'::numeric - (COALESCE(s.discount, '0'::numeric) / '100'::numeric))))) DESC
  Sort Method: quicksort  Memory: 26kB
  ->  HashAggregate  (cost=601.60..621.60 rows=1600 width=108) (actual time=6.427..6.436 rows=8 loops=1)
        Group Key: s.seller_id, sel.first_name, sel.last_name
        Batches: 1  Memory Usage: 73kB
        ->  Nested Loop  (cost=107.69..476.20 rows=5016 width=83) (actual time=0.200..3.331 rows=4979 loops=1)
              ->  Hash Join  (cost=107.39..346.41 rows=5016 width=79) (actual time=0.190..1.921 rows=4979 loops=1)
                    Hash Cond: (s.seller_id = sel.id)
                    ->  Bitmap Heap Scan on sales s  (cost=79.17..304.95 rows=5016 width=15) (actual time=0.163..0.850 rows=4979 loops=1)
                          Recheck Cond: (sale_date >= (CURRENT_DATE - '90 days'::interval))
                          Heap Blocks: exact=138
                          ->  Bitmap Index Scan on idx_sales_date_product  (cost=0.00..77.91 rows=5016 width=0) (actual time=0.147..0.147 rows=4979 loops=1)
                                Index Cond: (sale_date >= (CURRENT_DATE - '90 days'::interval))
                    ->  Hash  (cost=18.10..18.10 rows=810 width=68) (actual time=0.021..0.022 rows=8 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on sellers sel  (cost=0.00..18.10 rows=810 width=68) (actual time=0.005..0.006 rows=8 loops=1)
              ->  Memoize  (cost=0.30..0.50 rows=1 width=12) (actual time=0.000..0.000 rows=1 loops=4979)
                    Cache Key: s.product_id
                    Cache Mode: logical
                    Hits: 4971  Misses: 8  Evictions: 0  Overflows: 0  Memory Usage: 1kB
                    ->  Index Scan using products_pkey on products p  (cost=0.29..0.49 rows=1 width=12) (actual time=0.002..0.002 rows=1 loops=8)
                          Index Cond: (id = s.product_id)
Planning Time: 0.522 ms
Execution Time: 6.517 ms
```
</details>

**Комментарий:**
- Используется индекс `idx_sales_date_product` (btree) для фильтрации по дате.
- Memoize позволяет кешировать результаты для повторного использования при соединении с таблицей `products`.
- Составное хэш-соединение эффективно распределяет нагрузку между таблицами `sales` и `sellers`.


## Поиск товаров в ценовом диапазоне
```sql
EXPLAIN ANALYZE
SELECT name, sale_price
FROM products
WHERE sale_price BETWEEN 50000 AND 100000
ORDER BY sale_price;
```
<details>
<summary>QUERY PLAN</summary>

```
Sort  (cost=584.54..593.79 rows=3702 width=61) (actual time=3.188..3.449 rows=3687 loops=1)
  Sort Key: sale_price
  Sort Method: quicksort  Memory: 615kB
  ->  Seq Scan on products  (cost=0.00..365.12 rows=3702 width=61) (actual time=0.007..2.035 rows=3687 loops=1)
        Filter: ((sale_price >= '50000'::numeric) AND (sale_price <= '100000'::numeric))
        Rows Removed by Filter: 7321
Planning Time: 0.243 ms
Execution Time: 3.606 ms
```
</details>

**Комментарий:**
- Индекс `idx_products_price` (btree) не используется, так как диапазон охватывает значительную часть таблицы (3702 строки из 11008).
- PostgreSQL предпочитает последовательное сканирование (Seq Scan) из-за высокой селективности запроса.

## Поиск клиентов с картами лояльности
```sql
EXPLAIN ANALYZE
SELECT first_name, last_name, discount
FROM customers
WHERE discount_card = true
ORDER BY discount DESC;
```
<details>
<summary>QUERY PLAN</summary>

```
Sort  (cost=570.33..585.43 rows=6039 width=34) (actual time=2.797..3.030 rows=6039 loops=1)
  Sort Key: discount DESC
  Sort Method: quicksort  Memory: 664kB
  ->  Seq Scan on customers  (cost=0.00..191.08 rows=6039 width=34) (actual time=0.007..0.910 rows=6039 loops=1)
        Filter: discount_card
        Rows Removed by Filter: 4069
Planning Time: 0.149 ms
Execution Time: 3.206 ms
```
</details>

**Комментарий:**
- Индекс `idx_customers_discount` (partial btree) не используется из-за полного охвата таблицы (6039 строк).
- Последовательное сканирование предпочтительнее, так как все строки удовлетворяют условию фильтрации.

## Проверка наличия конкретного товара в отделах
```sql
EXPLAIN ANALYZE
SELECT d.name as department, i.quantity
FROM inventory i
JOIN departments d ON d.id = i.department_id
WHERE i.product_id = 500;
```
<details>
<summary>QUERY PLAN</summary>

```
Nested Loop  (cost=0.45..27.86 rows=3 width=36) (actual time=0.006..0.006 rows=0 loops=1)
  ->  Index Scan using idx_inventory_prod_dept on inventory i  (cost=0.29..11.84 rows=3 width=8) (actual time=0.005..0.005 rows=0 loops=1)
        Index Cond: (product_id = 500)
  ->  Memoize  (cost=0.16..6.84 rows=1 width=36) (never executed)
        Cache Key: i.department_id
        Cache Mode: logical
        ->  Index Scan using departments_pkey on departments d  (cost=0.15..6.83 rows=1 width=36) (never executed)
              Index Cond: (id = i.department_id)
Planning Time: 0.261 ms
Execution Time: 0.029 ms
```
</details>

**Комментарий:**
- Индекс `idx_inventory_prod_dept` (btree) используется для быстрого доступа к строкам, соответствующим фильтру `product_id = 500`.
- Memoize позволяет избежать повторных обращений к таблице `departments`, но в данном случае не используется, так как результат пустой.
- Время выполнения минимально благодаря индексации (0.029 мс).

# Заключение
Проведен анализ производительности запросов в PostgreSQL с использованием индексов. Были протестированы различные типы запросов, включая агрегацию, фильтрацию, сортировку и соединение таблиц, с оценкой их плана выполнения.

Полученные результаты:
1. Для фильтрации по дате использовался индекс idx_sales_date_product, что позволило сократить время выполнения запроса до 2.128 мс.
2. Анализ продаж по продавцам за 90 дней занял 6.517 мс, с применением индекса и оптимизацией за счет Memoize.
3. Последовательное сканирование (Seq Scan) оказалось предпочтительным для запросов с большим охватом данных (например, поиск товаров в ценовом диапазоне занял 3.606 мс).
4. Индексы в небольших таблицах, таких как customers и inventory, были эффективны, но из-за малых объемов данных PostgreSQL иногда выбирал последовательное сканирование.