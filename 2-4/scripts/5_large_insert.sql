CREATE OR REPLACE FUNCTION generate_sales_data(num_rows int) RETURNS void AS $$
DECLARE
    product_count int;
    seller_count int;
BEGIN
    SELECT COUNT(*) INTO product_count FROM products;
    SELECT COUNT(*) INTO seller_count FROM sellers;
    
    FOR i IN 1..num_rows LOOP
        INSERT INTO sales (product_id, seller_id, sale_date, quantity, discount)
        VALUES (
            floor(random() * product_count) + 1,
            floor(random() * seller_count) + 1,
            current_date - (random() * 365)::integer,
            floor(random() * 5) + 1,
            CASE WHEN random() > 0.5 THEN floor(random() * 20) ELSE 0 END
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Генерируем 10000 продаж
SELECT generate_sales_data(10000);

-- Функция для генерации случайного названия товара
CREATE OR REPLACE FUNCTION random_product_name() RETURNS text AS $$
DECLARE
    metals text[] := ARRAY['Золотое', 'Серебряное', 'Платиновое'];
    types text[] := ARRAY['кольцо', 'колье', 'браслет', 'серьги', 'подвеска'];
    stones text[] := ARRAY['с бриллиантом', 'с сапфиром', 'с рубином', 'с изумрудом', 'с жемчугом'];
BEGIN
    RETURN metals[1 + floor(random() * array_length(metals, 1))] || ' ' ||
           types[1 + floor(random() * array_length(types, 1))] || ' ' ||
           stones[1 + floor(random() * array_length(stones, 1))];
END;
$$ LANGUAGE plpgsql;

-- Генерация товаров (для проверки индекса по цене)
INSERT INTO products (name, description, purchase_price, sale_price, supplier_id)
SELECT 
    random_product_name(),
    'Описание товара ' || i,
    (random() * 90000 + 10000)::numeric(10,2),  -- purchase_price от 10000 до 100000
    (random() * 150000 + 20000)::numeric(10,2),  -- sale_price от 20000 до 170000
    1 + floor(random() * 4)  -- supplier_id от 1 до 4
FROM generate_series(1, 1000) i;

-- Генерация клиентов (для проверки индекса по картам лояльности)
INSERT INTO customers (first_name, last_name, discount_card, discount)
WITH names AS (
    SELECT unnest(ARRAY[
        'Александр', 'Михаил', 'Иван', 'Дмитрий', 'Андрей',
        'Елена', 'Мария', 'Анна', 'Ольга', 'Татьяна'
    ]) AS first_name,
    unnest(ARRAY[
        'Иванов', 'Петров', 'Сидоров', 'Смирнов', 'Кузнецов',
        'Иванова', 'Петрова', 'Сидорова', 'Смирнова', 'Кузнецова'
    ]) AS last_name
)
SELECT 
    n1.first_name,
    n2.last_name,
    random() < 0.6,  -- 60% клиентов имеют карту лояльности
    CASE 
        WHEN random() < 0.6 THEN (random() * 15)::numeric(4,1)
        ELSE 0
    END
FROM generate_series(1, 100) i
CROSS JOIN LATERAL (
    SELECT first_name 
    FROM names 
    OFFSET floor(random() * 10) 
    LIMIT 1
) n1
CROSS JOIN LATERAL (
    SELECT last_name 
    FROM names 
    OFFSET floor(random() * 10) 
    LIMIT 1
) n2;

-- Генерация записей инвентаря (для проверки индекса по товарам в отделах)
INSERT INTO inventory (product_id, department_id, quantity)
SELECT 
    p.id,
    d.id,
    floor(random() * 50 + 1)::integer  -- количество от 1 до 50
FROM products p
CROSS JOIN departments d
WHERE p.id <= 1000  -- для каждого товара
AND random() < 0.7;  -- 70% вероятность наличия товара в отделе

-- Обновление статистики после добавления данных
ANALYZE VERBOSE products;
ANALYZE VERBOSE customers;
ANALYZE VERBOSE inventory;