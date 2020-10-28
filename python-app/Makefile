DEBUG ?= 0

init:
	helm upgrade $(NAME) helm -f helm/values.yaml $(ARGS) --install --atomic --timeout 1m

build:
	docker build -t docker.pkg.github.com/oba11/hm-demo/60b15dd1 .

load: build
	kind load docker-image docker.pkg.github.com/oba11/hm-demo/60b15dd1

delete:
	helm uninstall $(NAME)

del: delete
rm: delete
