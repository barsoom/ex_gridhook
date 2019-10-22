all:
	@docker-compose build

test: all
	@docker-compose run app mix test

dev:
	@docker-compose run app ls
	@echo todo

sh:
	@docker-compose run app bash