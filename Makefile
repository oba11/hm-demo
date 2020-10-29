DEBUG ?= 0

init:
	helm upgrade $(NAME) charts/python-app -f charts/python-app/values.yaml $(ARGS) --install --wait --timeout 1m

build:
	docker build -t docker.pkg.github.com/oba11/hm-demo/60b15dd1 python-app/

load: build
	kind load docker-image docker.pkg.github.com/oba11/hm-demo/60b15dd1

delete:
	helm uninstall $(ARGS)

deploy-frontend:
	helm upgrade frontend charts/python-app -f charts/python-app/values.yaml --set upstreamUri=http://middleware-python-app --set ingress.enabled=true --set ingress.host=app.example.com --install --atomic --timeout 1m

deploy-middleware:
	helm upgrade middleware charts/python-app -f charts/python-app/values.yaml --set upstreamUri=http://backend-python-app --install --atomic --timeout 1m

deploy-backend: load
	helm upgrade backend charts/python-app -f charts/python-app/values.yaml --set ingress.enabled=true --set ingress.host=backend.example.com --install --atomic --timeout 1m

del: delete
rm: delete
