# НИЯУ МИФИ. Лабораторная работа №2-3

## Базовые задачи администрирования СУБД

### Журбенко Василий, Б21-525  
### 2024

---

## Цель работы

Изучение базовых задач администрирования СУБД PostgreSQL. Изучение изоляции контенерв в СУБД.

## На защиту
Остановите экземпляр СУБД и выясните, сколько занимает на диске весь кластер БД. Затем определите, во сколько раз его можно сжать алгоритмом zstd с максимальной степенью компрессии.

root@ubuntu-jammy:/home/vagrant# sudo systemctl stop postgresql

root@ubuntu-jammy:/var/lib/postgresql/14# du -sh main/
84M     main/
root@ubuntu-jammy:/var/lib/postgresql/14# sudo tar --zstd -cf postgresql_cluster.tar.zst -C /var/lib/postgresql/14/ main/
root@ubuntu-jammy:/var/lib/postgresql/14# ls -lh postgresql_cluster.tar.zst
-rw-r--r-- 1 root root 14M Jan 11 00:47 postgresql_cluster.tar.zst

---
## Ход работы

### 1. Выяснить, в каком месте файловой системы расположен установленный в предыдущих работах кластер баз данных PostgreSQL:

```bash
postgres@ubuntu-jammy:/vagrant/2-1/scripts$ psql -c 'SHOW config_file;'
               config_file
-----------------------------------------
 /etc/postgresql/14/main/postgresql.conf 
(1 row)
```

### 2. Выяснить, какие файлы хранятся в директории кластера базы данных:

```bash
postgres@ubuntu-jammy:/vagrant/2-1/scripts$ cd /etc/postgresql/14/main
postgres@ubuntu-jammy:/etc/postgresql/14/main$ ls
conf.d  environment  pg_ctl.conf  pg_hba.conf  pg_ident.conf  postgresql.conf  start.conf
# В директории кластера хранятся конфигурационные и служебные файлы.
```

### 3. Выяснить, какой командной строкой запущен экземпляр PostgreSQL:

```bash
postgres@ubuntu-jammy:/etc/postgresql/14/main$ systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2025-01-05 12:54:32 UTC; 1 day 4h ago
    Process: 5659 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 5659 (code=exited, status=0/SUCCESS)
        CPU: 1ms
postgres@ubuntu-jammy:/etc/postgresql/14/main$ ps aux | grep postgres
...
postgres    5641  0.0  2.5 218756 25044 ?        Ss   00:03   0:03 /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
# Сервер PostgreSQL запущен с указанными параметрами и директорией кластера.
```

### 4. Выполнить штатное завершение работы сервера PostgreSQL:

```bash
root@ubuntu-jammy:/home/vagrant# systemctl stop postgresql
root@ubuntu-jammy:/home/vagrant# systemctl status postgresql
○ postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Mon 2025-01-06 17:07:58 UTC; 7s ago
# Сервер PostgreSQL был успешно остановлен.
```

### 5. Вновь запустить экземпляр PostgreSQL вручную:

```bash
postgres@ubuntu-jammy:~$ /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
# Сервер запущен вручную от имени пользователя postgres.
```

### 6. Подключиться к экземпляру и проверить его работоспособность:

```sql
postgres@ubuntu-jammy:/vagrant/2-1/scripts$ psql
postgres=# SELECT version();
                                                                version
----------------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit
(1 row)
# Экземпляр PostgreSQL успешно функционирует.
```

### 7. Создать новую базу данных в кластере. Кто ее владелец? Какие объекты в ней содержатся?

```sql
postgres=# CREATE DATABASE test_db OWNER postgres;
CREATE DATABASE
postgres=# \l
                                List of databases
     Name      |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
---------------+----------+----------+---------+---------+-----------------------
 jewelry_store | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
               |          |          |         |         | postgres=CTc/postgres+
               |          |          |         |         | admin=CTc/postgres    
 postgres      | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0     | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
               |          |          |         |         | postgres=CTc/postgres 
 template1     | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
               |          |          |         |         | postgres=CTc/postgres 
 test_db       | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)
# Создана новая база test_db с владельцем postgres.

test_db=# \dt
Did not find any relations.
test_db=# \dv
Did not find any relations.
test_db=# \df
                       List of functions
 Schema | Name | Result data type | Argument data types | Type 
--------+------+------------------+---------------------+------
(0 rows)
```

### 8. Подключиться к новой базе данных и создать в ней несколько пробных объектов:

```sql
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# CREATE TABLE test_table (
    id serial PRIMARY KEY,
    name text,
    created_at timestamp DEFAULT current_timestamp
);
CREATE TABLE
test_db=# CREATE VIEW test_view AS SELECT * FROM test_table;
CREATE VIEW
test_db=# CREATE FUNCTION test_function() RETURNS text AS $$
BEGIN
    RETURN 'Hello from test_function';
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION
# Созданы таблица, вид и функция в базе test_db.
```

### 9-10. Убедиться, что из новой базы данных нет доступа к исходной и обратно:
```sql
test_db=# SELECT * FROM jewelry_store.public.departments;
ERROR:  cross-database references are not implemented: "jewelry_store.public.departments"
LINE 1: SELECT * FROM jewelry_store.public.departments;
test_db=# SELECT * FROM test_db.public.test_table;1~
 id | name | created_at
----+------+------------
(0 rows)
```


```bash
jewelry_store=# SELECT * FROM test_db.public.test_table;
ERROR:  cross-database references are not implemented: "test_db.public.test_table"
LINE 1: SELECT * FROM test_db.public.test_table;
```

## Заключение
В работе были исследованы транзакции в PostgreSQL, выявлено расположение кластера базы данных, проведено создание новой базы данных, объектов в ней и проверка доступов между базами.


<details>
<summary>Полная стенография</summary>
```bash
postgres@ubuntu-jammy:/vagrant/2-1/scripts$ psql -c 'SHOW config_file;'
               config_file
-----------------------------------------
 /etc/postgresql/14/main/postgresql.conf 
(1 row)

postgres@ubuntu-jammy:/vagrant/2-1/scripts$  cd  /etc/postgresql/14/main
postgres@ubuntu-jammy:/etc/postgresql/14/main$ ls
conf.d  environment  pg_ctl.conf  pg_hba.conf  pg_ident.conf  postgresql.conf  start.conf

3. Выяснить,какойкоманднойстрокойзапущенэкземплярPostgreSQL;
"postgres@ubuntu-jammy:/etc/postgresql/14/main$ systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2025-01-05 12:54:32 UTC; 1 day 4h ago
    Process: 5659 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 5659 (code=exited, status=0/SUCCESS)
        CPU: 1ms
postgres@ubuntu-jammy:/etc/postgresql/14/main$ ps aux | grep postgres
...
postgres    5507  0.0  0.5   9104  5036 pts/2    S    Jan05   0:00 -bash
postgres    5641  0.0  2.5 218756 25044 ?        Ss   00:03   0:03 /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
postgres    5643  0.0  1.2 218884 12364 ?        Ss   00:03   0:00 postgres: 14/main: checkpointer 
postgres    5644  0.0  0.8 218756  8452 ?        Ss   00:03   0:00 postgres: 14/main: background writer 
postgres    5645  0.0  1.1 218756 10992 ?        Ss   00:03   0:00 postgres: 14/main: walwriter 
postgres    5646  0.0  0.8 219324  8712 ?        Ss   00:03   0:01 postgres: 14/main: autovacuum launcher 
postgres    5647  0.0  0.6  73484  6456 ?        Ss   00:03   0:01 postgres: 14/main: stats collector 
postgres    5648  0.0  0.7 219184  7088 ?        Ss   00:03   0:00 postgres: 14/main: logical replication launcher "

4, 5
"root@ubuntu-jammy:/home/vagrant# systemctl stop postgresql
root@ubuntu-jammy:/home/vagrant# systemctl status postgresql
○ postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Mon 2025-01-06 17:07:58 UTC; 7s ago
    Process: 5659 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 5659 (code=exited, status=0/SUCCESS)
        CPU: 1ms

Jan 05 12:54:32 ubuntu-jammy systemd[1]: Starting PostgreSQL RDBMS...
Jan 05 12:54:32 ubuntu-jammy systemd[1]: Finished PostgreSQL RDBMS.
Jan 06 17:07:58 ubuntu-jammy systemd[1]: postgresql.service: Deactivated successfully.
Jan 06 17:07:58 ubuntu-jammy systemd[1]: Stopped PostgreSQL RDBMS.
root@ubuntu-jammy:/home/vagrant#  /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf 
"root" execution of the PostgreSQL server is not permitted.        
The server must be started under an unprivileged user ID to prevent
possible system security compromise.  See the documentation for    
more information on how to properly start the server.
root@ubuntu-jammy:/home/vagrant# sudo -i -u postgres
postgres@ubuntu-jammy:~$  /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
2025-01-06 17:09:04.909 UTC [16128] LOG:  starting PostgreSQL 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 
11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit
2025-01-06 17:09:04.909 UTC [16128] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2025-01-06 17:09:04.910 UTC [16128] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2025-01-06 17:09:04.918 UTC [16129] LOG:  database system was shut down at 2025-01-06 17:07:58 UTC
2025-01-06 17:09:04.928 UTC [16128] LOG:  database system is ready to accept connections"

"postgres@ubuntu-jammy:/vagrant/2-1/scripts$ psql
psql (14.15 (Ubuntu 14.15-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# SELECT version();
                                                                version
----------------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit
(1 row)
"

"postgres=# CREATE DATABASE test_db OWNER postgres;
CREATE DATABASE
postgres=# \l  
                                List of databases
     Name      |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
---------------+----------+----------+---------+---------+-----------------------
 jewelry_store | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
               |          |          |         |         | postgres=CTc/postgres+
               |          |          |         |         | admin=CTc/postgres    
 postgres      | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0     | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
               |          |          |         |         | postgres=CTc/postgres 
 template1     | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
               |          |          |         |         | postgres=CTc/postgres 
 test_db       | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
(5 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \dt
Did not find any relations.
test_db=# \dv
Did not find any relations.
test_db=# \df
                       List of functions
 Schema | Name | Result data type | Argument data types | Type 
--------+------+------------------+---------------------+------
(0 rows)"


"test_db=# CREATE TABLE test_table ( 
test_db(#     id serial PRIMARY KEY,
test_db(#     name text,
p
);test_db(#     created_at timestamp DEFAULT current_timestamp
test_db(# );
CREATE TABLE
test_db=# CREATE VIEW test_view AS 
test_db-# SELECT * FROM test_table;
CREATE VIEW
test_db=# CREATE FUNCTION test_function() 
test_db-# RETURNS text AS $$
test_db$# BEGIN
test_db$#     RETURN 'Hello from test_function';
test_db$# END;
test_db$# $$ LANGUAGE plpgsql;
CREATE FUNCTION              
test_db=# SELECT * FROM jewelry_store.public.departments;
ERROR:  cross-database references are not implemented: "jewelry_store.public.departments"
LINE 1: SELECT * FROM jewelry_store.public.departments;
                      ^
test_db=# SELECT * FROM test_db.public.test_table;1~
 id | name | created_at
----+------+------------
(0 rows)"

"jewelry_store=# SELECT * FROM test_db.public.test_table;
ERROR:  cross-database references are not implemented: "test_db.public.test_table"
LINE 1: SELECT * FROM test_db.public.test_table;"
```
</details>
