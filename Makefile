DEBUG ?= 0

init:
	helm upgrade $(NAME) charts/python-app -f charts/python-app/values.yaml $(ARGS) --install --wait --timeout 1m

build:
	docker build -t docker.pkg.github.com/oba11/hm-demo/60b15dd1 python-app/

load: build
	kind load docker-image docker.pkg.github.com/oba11/hm-demo/60b15dd1

delete:
	helm uninstall $(NAME)

del: delete
rm: delete
