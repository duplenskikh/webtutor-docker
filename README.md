# Запуск WebTutor в docker

# До запуска
1. Загружаем образ `WebTutor` в `docker` командой `docker load -i ${WEBTUTOR_IMAGE.tar.gz}`
2. Настраиваем `.env` файл

## Запуск

1. Запускаем контейнеры командой `make start`
2. Создаем схему в БД для WebTutor
3. Создаем пользователя в БД для работы из под `WebTutor`
4. Подключаемся к контейнеру `WebTutor` и настраиваем на работу с необходимой БД через `x-shell`
5. Перезагружаем контейнер с `WebTutor` с помощью `docker-compose restart wt`
## Работа

1. База доступна по порту `MSSQL_HOST_PORT`
2. `WebTutor` доступен по порту `WEBTUTOR_HOST_PORT`
3. `mailhog` доступен по порту `MAILHOG_HOST_PORT`

## Подключение к контейнеру docker

Можно произвести командой `docker exec -it wt bash`
