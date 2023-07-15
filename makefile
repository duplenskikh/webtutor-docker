up:
	docker-compose up --build -d

down:
	docker-compose stop && docker-compose down

re:
	make down && make up
