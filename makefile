start:
	# docker load -i hcm_2021.4.3.406.tar.gz
	docker-compose up --build -d

stop:
	docker-compose stop && docker-compose down

restart:
	make stop && make start
