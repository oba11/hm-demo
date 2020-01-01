# Python App

Simple Python app using Flask to output the hostname and the ip address of the container

## Getting Started

```
docker run -it -p 8080:80 docker.pkg.github.com/oba11/hm-demo/app
```

## Testing locally

### Prerequisites
* Install docker-compose.

## Starting the container

```
$ docker-compose up
```

##Using Helm

```
make NAME=backend
make NAME=middleware ARGS='--set upstreamUri=http://backend-python-app'
make NAME=frontend ARGS='--set upstreamUri=http://middleware-python-app --set ingress.enabled=true --set ingress.host=*'
```
