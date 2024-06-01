# НИЯУ МИФИ. Лабораторная работа №1. Журбенко Василий, Б21-525. 2024

[Дополнительное задание](#дополнительное-задание)

## Предметная область

Сеть магазинов ювелирных изделий. После поступления на склад, изделия распределяются по различным отделам. Необходимо вести учёт наличия товаров в каждом отделе и отслеживать личные продажи продавцов. Важной частью системы является программа лояльности для постоянных покупателей, которая предусматривает скидки. Магазины работают с несколькими поставщиками.  Нужно учитывать, что один и тот же товар может находиться в разных отделах и в разном количестве. Система должна также отслеживать данные о поставщиках, продаже товаров, продавцах, покупателях и инвентаре.

## Спецификация таблиц

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

## Доказательство соответствия базы данных требованиям третьей нормальной формы (3NF)

1. **Первая нормальная форма (1NF)**:
   - Все данные в таблицах разбиты на простые и неделимые значения.
   - Каждое поле в таблице содержит только одно значение.

2. **Вторая нормальная форма (2NF)**:
   - Соответствует 1NF.
   - Все данные зависят от всего первичного ключа таблицы.
   - Нет частичных зависимостей, то есть данные зависят от всего ключа, а не от его части.

3. **Третья нормальная форма (3NF)**:
   - Соответствует 2NF.
   - Все данные зависят только от первичного ключа и ни от чего другого.
   - Нет транзитивных зависимостей, когда данные зависят от другого неключевого поля.

Таким образом, наша база данных соответствует требованиям третьей нормальной формы (3NF), потому что:
   - Данные простые и неделимые (1NF).
   - Все данные зависят от ключа целиком (2NF).
   - Данные зависят только от ключа и ни от чего другого (3NF).

## Диаграмма отношений сущностей
![//www.plantuml.com/plantuml/png/hLF1Ri8m3BttAq9Fuu1sdn3YJweqCM0jJRh4GLImVv_fshICJ0Y94yJlvVazEzq6afvYOue57Q01SSJQIql5GiCEBOZMOoDzLtr2ztPQYdMzEQtVwqt2Tyu3xct2yOhZfYZ04b8dIWqjTsZu64fnBiID8kgb-11eYUjMDi27G1xjdi_6AKdex5JxdbHRxtHKpqfg2CfZUwlArwDN1ncWOXt55vYdMD0m5AJ9bUUfGsnRW-2hr7bkT4IVTAgS9QceGhjpsG5SZJtGd9iSvbNzXmSmPXvXZAubzSdvXqjVKVRj4qTZK2vQceOpz_Wh-iWb-a3LtV9bfZWtF3sh_DnL3EIQrtMVibPAUir0xPm1QHzE0UsH_phVlMfR-V3tws4F4p68osMrScSnB8KvvOrCcICdxndwO3BF7S0iiN-wVqdZTv9OwHOJHx1d3W7krAxrWR85gsDZVW00](./assets/diagram.png)

## SQL-сценарий
[Инициализация](./scripts/initialization.sql)

## Заключение
В ходе данной лабораторной работы была построена модель данных для предметной области "Сеть магазинов ювелирных изделий". Разработанная модель включает в себя следующие основные сущности: отделы, товары, поставщики, продажи, продавцы, покупатели и инвентарь. Все необходимые атрибуты этих сущностей были определены и сгруппированы в соответствующие таблицы.
Было доказано, что разработанная модель данных соответствует требованиям третьей нормальной формы, что обеспечивает целостность и непротиворечивость хранимых данных. Для наглядного представления взаимосвязей между сущностями была построена диаграмма отношений сущностей.
Разработанная модель данных была реализована с помощью SQL-сценария, создающего необходимые таблицы и устанавливающего связи между ними.
Полученная в результате работы модель данных может быть использована для дальнейшей разработки информационной системы для управления сетью магазинов ювелирных изделий.


# Дополнительное задание

## Обновленная диаграмма
![//www.plantuml.com/plantuml/png/hPDDRjmm38NtFeNYLRC8kY-2GMuYo1AT49KfLpz1ZAHtB-tQKbKh2GBCQaPydqW-Kdu8KVcO9jlTn2UOG3pZu1N5xiR0Y0HYzZWflyYVi7nxkHNtm-Nb_ljmoVheFE0ZPHrN7IzT1nGnBg8tC7E5YO-X5w-Tg3AYkHK_15BaEAa9-12YHthaitLQHNHKOhzBrjaxa_HNKne8skDSP-NhoUid5K1o7iqNcDESqB8Kb6s4AzSXpRD5y39N_hVHG_rYfzfHL3fAfD4r1x0s5YItJGJsEcCm6BHB5EN8bPqlXazrFonN3MVVatnF3s0j-7TbdK9qqmT0DOP27PipAW97rXyE_KfgSt4msN7Rwj_UFZEBFaHvUhlg7ApwBbz5-zaSngzNFMzNAszO69opeEZJAI0zyr_db-ijlMc-hATCeu11lBtTtRbNiI-5cRvAqxVWt7i3tvjiixlO1BSdzp-KF_E3ohSOFCIDt0sSigtn7SdBFq67ic7Lsp-pbRnTU00oQR9_0000](./assets/diagram_2.png)

1. **Связь таблицы `customers` с таблицей `sales`**:
   > Оказавшуюся отдельно таблицу Customers можно легко связать с Sales и, тем самым, сделать частью общей системы: магазины систематически и очень агрессивно этим занимаются

   ```sql
   CREATE TABLE customers (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       first_name TEXT NOT NULL,
       last_name TEXT NOT NULL,
       discount_card BOOLEAN NOT NULL,
       discount REAL
   );

   CREATE TABLE sales (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       product_id INTEGER,
       seller_id INTEGER,
       customer_id INTEGER,
       sale_date DATE NOT NULL,
       quantity INTEGER NOT NULL,
       discount REAL,
       sales_channel_id INTEGER,
       FOREIGN KEY (product_id) REFERENCES products(id),
       FOREIGN KEY (seller_id) REFERENCES sellers(id),
       FOREIGN KEY (customer_id) REFERENCES customers(id),
       FOREIGN KEY (sales_channel_id) REFERENCES sales_channels(id)
   );
   ```

2. **Хранение сведений о каналах продаж**:
   > пусть есть несколько каналов продажи: с доставкой курьером, личным визитом в магазин (и, может, что-нибудь ещё). Может быть такое, что скидка применяется только при покупке тем  или иным способом. Предусмотрите хранение таких сведений в БД

   Добавлена таблица `sales_channels`, которая позволяет хранить информацию о различных каналах продаж. В этой таблице хранится коэффициент скидки, который может применяться в зависимости от канала продаж.

   ```sql
   CREATE TABLE sales_channels (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       name TEXT NOT NULL,
       description TEXT,
       discount_factor REAL NOT NULL
   );
   ```

   Поле `sales_channel_id` в таблице `sales` связывает каждую продажу с определённым каналом продаж, что позволяет точно отслеживать, каким образом была совершена покупка и какие скидки были применены.

   ```sql
   CREATE TABLE sales (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       product_id INTEGER,
       seller_id INTEGER,
       customer_id INTEGER,
       sale_date DATE NOT NULL,
       quantity INTEGER NOT NULL,
       discount REAL,
       sales_channel_id INTEGER,
       FOREIGN KEY (product_id) REFERENCES products(id),
       FOREIGN KEY (seller_id) REFERENCES sellers(id),
       FOREIGN KEY (customer_id) REFERENCES customers(id),
       FOREIGN KEY (sales_channel_id) REFERENCES sales_channels(id)
   );
   ```

## Обновлённый SQL-сценарий
[Инициализация 2](./scripts/init_2.sql)

