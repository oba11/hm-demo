DEBUG ?= 0

init:
	helm3 upgrade $(NAME) helm -f helm/values.yaml $(ARGS) --install --atomic --timeout 1m

build:
	docker build -t docker.pkg.github.com/oba11/hm-demo/hm-demo .

load: build
	kind load docker-image docker.pkg.github.com/oba11/hm-demo/hm-demo

delete:
	helm3 uninstall $(NAME)

del: delete
rm: delete
