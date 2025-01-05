

## Разделение на схемы
В данный момент все таблицы находятся в схеме public (схема по умолчанию в PostgreSQL). Для ювелирного магазина имеет смысл разделить базу данных на несколько схем:



```sql
-- Создание схем
CREATE SCHEMA store_operations;    -- Для основных операций магазина
CREATE SCHEMA inventory_management; -- Для управления запасами
CREATE SCHEMA hr;                  -- Для управления персоналом
CREATE SCHEMA sales_analytics;     -- Для аналитики продаж
```

Причины разделения на схемы:
1. Логическое разделение функционала
2. Улучшение безопасности и контроля доступа
3. Упрощение администрирования
4. Улучшение организации и поддержки кода

## Роли и привилегии:

Основные роли:

1. store_manager (Менеджер магазина)
- Системные привилегии: USAGE на все схемы
- Объектные привилегии: ALL на все таблицы
- Полный доступ ко всем данным

2. inventory_manager (Менеджер по запасам)
- Схема: inventory_management
- Привилегии: ALL на таблицы inventory и suppliers
- SELECT на products

3. hr_manager (HR-менеджер)
- Схема: hr
- Привилегии: ALL на таблицы departments и sellers

4. sales_analyst (Аналитик продаж)
- Схема: sales_analytics, store_operations
- Привилегии: SELECT на все таблицы для анализа

5. cashier (Кассир)
- Схема: store_operations
- Привилегии: 
  - SELECT, INSERT на sales
  - SELECT на products и customers

Вложенная роль:
- senior_cashier (Старший кассир)
  - Наследует все привилегии cashier
  - Дополнительно: UPDATE на sales и customers

Причины такой организации ролей:
1. Принцип наименьших привилегий
2. Четкое разделение ответственности
3. Упрощение управления доступом
4. Возможность аудита действий пользователей
5. Масштабируемость системы безопасности

### Выдача ролей

![](assets/Screenshot_8.png)
![](assets/Screenshot_3.png)

### Проверка ролей
![](assets/Screenshot_2.png)
![](assets/Screenshot_3.png)
![](assets/Screenshot_4.png)
![](assets/Screenshot_5.png)
![](assets/Screenshot_6.png)
![](assets/Screenshot_7.png)