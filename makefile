start:
	docker-compose up --build -d

stop:
	docker-compose stop && docker-compose down

restart:
	make stop && make start && echo 'All containers started'
