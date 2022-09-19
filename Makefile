APT_PROXY ?=
DOCKER ?= docker

all:

build:
	$(DOCKER) build --build-arg APT_PROXY="$(APT_PROXY)" -t ghcr.io/seravo/fastapi:latest .

run: build
	$(DOCKER) run --rm --volume $(shell pwd)/app:/app -e FASTAPI_APP=app.hello:app -p 127.0.0.1:8080:8000 ghcr.io/seravo/fastapi:latest