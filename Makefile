NAME = dariusbakunas/kippo
VERSION = devel

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm=true .
