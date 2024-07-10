# WebSoft HCM в Docker

## Установка

1. Установить [Docker](https://www.docker.com/products/docker-desktop)
2. Скачать образ **WebSoft HCM**
2. Загрузить образ **WebSoft HCM** в **docker** командой `docker load -i {path_to_image}`
3. Запустить необходимую конфигурацию контейнеров `docker compose -f {compose_configuration_file_path} up -d`
5. Подключиться к контейнеру **WebSoft HCM**
6. Настроить неоходимую БД (дополнительные скрипты в директории **misc**) через утилиту __./xhttp.out__

## Работа

1. **postgresdb** доступна по порту __5433__ / **mssql** доступна по порту __1434__
2. **WebSoft HCM** доступен по порту __80__
3. **mailpit** доступен по порту __8025__

## Подключение к контейнеру docker

Подключиться к контейнеру можно командой `docker exec -it wt bash`

## Создание контейнера WT под MSSQL

1. Запускаешь **docker compose -f wt-mssql.yml -d up**
2. Подключиться к контейнеру **docker exec -ti {WT_container} bash**
3. Запустить **./xhttp.out**
4. Установить тип БД MSSQL **db set type mssql** (адрес сервера указывать **host.docker.internal**)
5. Исполнить файл в БД **misc/create_mssql_db.sql**
6. Запустить миграцию данных с XML БД **db migrate from xml**