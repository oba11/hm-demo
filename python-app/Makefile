DEBUG ?= 0

init:
	helm3 upgrade $(NAME) helm -f helm/values.yaml $(ARGS) --install --wait --timeout 1m

build:
	docker build -t oba11/python-app .

load: build
	kind load docker-image oba11/python-app

delete:
	helm3 uninstall $(NAME)

del: delete
rm: delete
