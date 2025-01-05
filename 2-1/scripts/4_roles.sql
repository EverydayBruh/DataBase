-- Создание схем
CREATE SCHEMA store_operations;    -- Для основных операций магазина
CREATE SCHEMA inventory_management; -- Для управления запасами
CREATE SCHEMA hr;                  -- Для управления персоналом
CREATE SCHEMA sales_analytics;     -- Для аналитики продаж

-- Перемещение таблиц в соответствующие схемы
ALTER TABLE products SET SCHEMA store_operations;
ALTER TABLE sales SET SCHEMA store_operations;
ALTER TABLE customers SET SCHEMA store_operations;

ALTER TABLE inventory SET SCHEMA inventory_management;
ALTER TABLE suppliers SET SCHEMA inventory_management;

ALTER TABLE departments SET SCHEMA hr;
ALTER TABLE sellers SET SCHEMA hr;

-- Создание представлений для аналитики в схеме sales_analytics
CREATE VIEW sales_analytics.daily_sales AS
SELECT 
    s.sale_date,
    p.name as product_name,
    SUM(s.quantity) as total_quantity,
    SUM(s.quantity * p.sale_price * (1 - COALESCE(s.discount, 0))) as total_revenue
FROM store_operations.sales s
JOIN store_operations.products p ON s.product_id = p.id
GROUP BY s.sale_date, p.name;

-- Создание ролей
ALTER ROLE store_manager LOGIN;
ALTER ROLE inventory_manager LOGIN;
ALTER ROLE hr_manager LOGIN;
ALTER ROLE sales_analyst LOGIN;
ALTER ROLE cashier LOGIN;
ALTER ROLE senior_cashier LOGIN;

-- Назначение привилегий для store_manager
GRANT USAGE ON SCHEMA store_operations TO store_manager;
GRANT USAGE ON SCHEMA inventory_management TO store_manager;
GRANT USAGE ON SCHEMA hr TO store_manager;
GRANT USAGE ON SCHEMA sales_analytics TO store_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA store_operations TO store_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA inventory_management TO store_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO store_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sales_analytics TO store_manager;

-- Назначение привилегий для inventory_manager
GRANT USAGE ON SCHEMA inventory_management TO inventory_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA inventory_management TO inventory_manager;
GRANT SELECT ON store_operations.products TO inventory_manager;

-- Назначение привилегий для hr_manager
GRANT USAGE ON SCHEMA hr TO hr_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO hr_manager;

-- Назначение привилегий для sales_analyst
GRANT USAGE ON SCHEMA sales_analytics TO sales_analyst;
GRANT USAGE ON SCHEMA store_operations TO sales_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA sales_analytics TO sales_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA store_operations TO sales_analyst;

-- Назначение привилегий для cashier
GRANT USAGE ON SCHEMA store_operations TO cashier;
GRANT SELECT, INSERT ON store_operations.sales TO cashier;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE store_operations.sales_id_seq TO cashier;
GRANT SELECT ON store_operations.products TO cashier;
GRANT SELECT ON store_operations.customers TO cashier;

-- Создание вложенной роли для старшего кассира
GRANT cashier TO senior_cashier;
GRANT UPDATE ON store_operations.sales TO senior_cashier;
GRANT UPDATE ON store_operations.customers TO senior_cashier;