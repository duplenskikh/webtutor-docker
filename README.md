# WebTutor

## Запуск

1. Загружаем образ `WebTutor` в `docker` командой `docker load -i ${webtutor_image.tar.gz}`
2. Прописываем название загруженного образа в переменную `WEBTUTOR_IMAGE_NAME` в файле .env
3. Запускаем командой `make start` образы:
4. Настраиваем базу данных.

## Подключение к контейнеру docker

Можно произвести командой `docker exec -it wt bash`
