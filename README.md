# WebTutor в docker

## Установка

1. Загружаем образ **WebTutor** в **docker** командой `docker load -i ${путь_до_образа}`
2. Запускаем контейнеры командой `docker-compose up -d`
3. Исполняем sql скрипт **misc/create_postgresql_db.sql** в бд
4. Подключаемся к контейнеру **WebTutor**, запускаем __./xhttp.out__ и настраиваем на работу с postgresql через **x-shell**

## Работа

1. **postgresdb** доступна по порту __5433__
2. **WebTutor** доступен по порту __80__
3. **mailpit** доступен по порту __8025__

## Подключение к контейнеру docker

Можно произвести командой `docker exec -it wt bash`
