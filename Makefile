COMPOSE=docker compose

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down -v

clean: down
# 	rm -rf out && mkdir -p out
	rd /s /q out && mkdir out

all: clean up
