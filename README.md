# Домашнее задание к занятию " `Репликация и масштабирование. Часть 1` " - `Сулименков Алексей`

---

## Задание 1

На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

### Ответ

- master-slave
  Master записывает обновления/изменения БД (запросы) в бинарный лог. А серверы-реплики (slave серверы) настроены таким образом, что читают бинарный лог с мастера и выполняют на своей базе данных те же самые запросы, которые выполнились на мастере. Каждая реплика получает полную копию бинарного лога и именно реплика отвечает за то, чтобы выполнить все (или не все, а только не/отфильтрованные или только для заданных таблиц/БД) запросы из полученного лог-файла.
  Slave-сервер понимает откуда начать читать лог, исходя из заданных координат при настройке репликации: имя файла лога, позиция в этом файле. Т.к. реплика хранит/сдвигает эти координаты в процессе прохождения по логу, реплика в любой момент может быть отключена от мастера и подключена снова. При этом, обработка лога продолжится с места на котором произошла остановка.

- master-master
  Репликация MySQL в режиме мастер-мастер подразумевает то, что в случае отказа одного из серверов – другие участники репликации прозрачно подхватят работу. То есть не нужно будет делать ручных шагов для перевода сервера роли Slave-сервера в Master (что вызовет перерыв сервиса). Круговая репликация (или circular replication) MySQL может быть использована для масштабирования MySQL нодов, доступных на запись (изменение базы данных). Но есть нюансы. В данной конфигурации, MySQL не выполняет разрешение конфликтов, то есть нет реализованного протокола, который отслеживает блокировки таблиц\баз между нодами

---

## Задание 2

Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.

Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.

### Ответ

Подготовлен docker-compose файл(все файлы для деплоя так же приложены)

<details> <summary>docker-compose</summary>

```yaml
services:
  mysql-master:
    image: mysql:latest
    container_name: mysql-master
    volumes:
      - ./mysql-master:/var/lib/mysql
      - ./master/master.cnf:/etc/mysql/conf.d/master.cnf
      - ./master/master.sql:/docker-entrypoint-initdb.d/start.sql
    environment:
      MYSQL_ROOT_PASSWORD: "root"
      MYSQL_USER: replication_user
      MYSQL_PASSWORD: replication_user
    ports:
      - "3306:3306"
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - overlay
    restart: always

  mysql-slave1:
    image: mysql:latest
    container_name: mysql-slave1
    volumes:
      - ./mysql-slave:/var/lib/mysql
      - ./slave/slave1.cnf:/etc/mysql/conf.d/slave1.cnf
    depends_on:
      - mysql-master
    environment:
      MYSQL_ROOT_PASSWORD: "root"
      MYSQL_USER: replication_user
      MYSQL_PASSWORD: replication_user
    ports:
      - "3307:3306"
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - overlay
    restart: always

networks:
  overlay:
```

</details>

Выполняем на SLAVE1

```SQL
  CHANGE REPLICATION SOURCE TO
SOURCE_HOST='mysql-master',
SOURCE_USER='replication_user',
SOURCE_PASSWORD='replication_user',
SOURCE_LOG_FILE='mysql-bin.000003',
SOURCE_LOG_POS=158,
SOURCE_PORT=3306,
SOURCE_SSL = 0,
SOURCE_SSL_VERIFY_SERVER_CERT=0,
GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;
```

Где значения SOURCE_LOG_FILE и SOURCE_LOG_POS получили, привыполнении команыды(см. ниже), на мастере

```SQL
SHOW BINARY LOG STATUS\G
```

<details> <summary>Скриншот к заданию 2 Primary</summary>

![task2](https://github.com/biparasite/DB-12-06HW/blob/main/task2.2.png "task2")

</details>

<details> <summary>Скриншот к заданию 2 Replica</summary>

![task2](https://github.com/biparasite/DB-12-06HW/blob/main/task2.1.png "task2")

</details>

---
