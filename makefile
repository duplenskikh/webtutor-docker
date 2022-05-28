setup:
	docker load -i hcm_2021.4.3.406.tar.gz

start:
	docker-compose up --build -d

stop:
	docker-compose stop && docker-compose down

restart:
	make stop && make start && echo 'All done'
