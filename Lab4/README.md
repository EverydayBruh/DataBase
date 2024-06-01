# НИЯУ МИФИ. Лабораторная работа №4. Журбенко Василий, Б21-525. 2024

## SQL сценарии
1. [Инициализация](./scripts/1_init_db.sql)
2. [Заполнение](./scripts/2_insert_db.sql)
3. [Select-запросы](./scripts/3_select.sql)

## Настройка PostgreSQL

Была выполнена установка и настройка PostgreSQL на операционной системе Ubuntu.

Установка сервера PostgreSQL и дополнительных утилит:

```
sudo apt install postgresql postgresql-contrib
```
Запуск сервера:

```
sudo service postgresql start
```

Для работы с сервером PostgreSQL необходимо переключиться на системного пользователя postgres:

```
sudo -i -u postgres
```

Создана новая база данных jewelry_store:

```
postgres=# CREATE DATABASE jewelry_store;
```

И выполнено подключение к созданной базе данных:

```
postgres=# \c jewelry_store
```

После этого можно было приступать к выполнению SQL-запросов для создания таблиц, вставки данных и работы с базой данных jewelry_store.

## Миграция SQLite -> PostgreSQL

### Инициализация
Основные изменения:

1. Использование `SERIAL` для автоинкрементных первичных ключей вместо `INTEGER PRIMARY KEY AUTOINCREMENT`.
```sql
id INTEGER PRIMARY KEY AUTOINCREMENT -- SQLite3
id SERIAL PRIMARY KEY -- PostgreSQL
```
2. Использование `NUMERIC` для столбцов с числовыми значениями вместо `REAL`.
```sql
purchase_price REAL NOT NULL, -- SQLite3
sale_price REAL NOT NULL

purchase_price NUMERIC NOT NULL, -- PostgreSQL
sale_price NUMERIC NOT NULL
```
3. Добавление `NOT NULL` для внешних ключей, ссылающихся на другие таблицы.
```sql
FOREIGN KEY (supplier_id) REFERENCES suppliers(id) -- SQLite3
FOREIGN KEY (supplier_id) REFERENCES suppliers(id) NOT NULL -- PostgreSQL
```
4. Порядок создания таблиц важен, когда есть внешние ключи.

В PostgreSQL нет эквивалента `AUTOINCREMENT` SQLite, поэтому для автоинкрементных первичных ключей используется `SERIAL`. Кроме того, PostgreSQL использует тип `NUMERIC` для чисел с плавающей точкой вместо `REAL`. Также в PostgreSQL необходимо явно указывать `NOT NULL` для внешних ключей, ссылающихся на другие таблицы.

### Заполнение
Основные изменения:
1. Использование true/false для логических значений вместо 0/1:

```sql
('Елена', 'Иванова', true, 10.0), -- PostgreSQL
('Елена', 'Иванова', 1, 10.0), -- SQLite3
```

2. Нет необходимости приводить типы данных вручную, если они соответствуют типу столбца:

```sql
INSERT INTO sales (product_id, seller_id, sale_date, quantity, discount) VALUES
(1, 1, '2023-05-01', 1, 10.0), -- PostgreSQL автоматически приводит типы

INSERT INTO sales (product_id, seller_id, sale_date, quantity, discount) VALUES
(1, 1, '2023-05-01', CAST(1 AS INTEGER), CAST(10.0 AS REAL)), -- В SQLite3 нужно явное приведение
```

3. Соблюдение ограничений целостности данных (внешние ключи, уникальные ограничения) более строгое в PostgreSQL. SQLite3 может позволить вставку данных, нарушающих эти ограничения.

4. Порядок вставки записей в таблицы с внешними ключами важен в PostgreSQL. Сначала нужно вставить записи в таблицы, на которые ссылаются внешние ключи. В SQLite3 этот порядок не имеет значения.

В остальном синтаксис INSERT INTO практически идентичен между PostgreSQL и SQLite3 для простых случаев вставки данных в таблицы.

### Select-запросы
Основные изменения:
1. Получение записей за последний месяц:

В SQLite3 используется следующий запрос:

```sql
WHERE s.sale_date >= DATE('now', '-1 month')
```

Здесь функция `DATE('now', '-1 month')` возвращает дату, соответствующую первому дню прошлого месяца относительно текущей даты.

В PostgreSQL эта же операция выполняется с помощью функции `DATE_TRUNC` и интервала:

```sql
WHERE s.sale_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
```

Функция `DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')` обрезает дату до начала месяца, а затем вычитает интервал 1 месяц, возвращая первый день прошлого месяца.

2. Условие в предложении WHERE для числовых значений:

В SQLite3 для сравнения числового значения со столбцом используется подзапрос:

```sql
WHERE c.discount > (SELECT 5.0);
```

Здесь `(SELECT 5.0)` создает скалярный подзапрос, возвращающий значение 5.0.

В PostgreSQL можно напрямую использовать числовое значение в условии:

```sql
WHERE c.discount > 5.0;
```

Нет необходимости заключать числовое значение в подзапрос.

3. Обработка NULL значений:

В SQLite3 для обработки NULL значений используется функция `IFNULL`:

```sql
SUM(s.quantity * p.sale_price * (1 - IFNULL(s.discount, 0)))
```

Здесь `IFNULL(s.discount, 0)` заменяет NULL значения в столбце `s.discount` на 0.

В PostgreSQL для этой цели используется функция `COALESCE`:

```sql
SUM(s.quantity * p.sale_price * (1 - COALESCE(s.discount, 0)))
```

Функция `COALESCE` возвращает первое не NULL значение из списка аргументов.

Остальные части запросов, такие как использование `JOIN`, `GROUP BY`, `ORDER BY` и оконных функций, работают одинаково в PostgreSQL и SQLite3, за исключением небольших синтаксических различий.

## Заключение

В ходе выполнения данной лабораторной работы была изучена процедура установки и первичной настройки сервера PostgreSQL, а также процедура подключения к серверу. Была реализована база данных, аналогичная созданной ранее в SQLite3, с использованием PostgreSQL.
Были рассмотрены основные отличия между этими двумя системами управления базами данных. В частности, различия в синтаксисе создания таблиц, вставки данных и выполнения запросов, а также различия в работе с внешними ключами, типами данных, логическими значениями и обработкой NULL в PostgreSQL.
Выполнение лабораторной работы позволило на практике ознакомиться с возможностями PostgreSQL, а также лучше понять ее преимущества и недостатки по сравнению с более простой встраиваемой СУБД SQLite3.