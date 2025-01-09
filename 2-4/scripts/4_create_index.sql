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