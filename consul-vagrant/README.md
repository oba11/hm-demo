# Consul Cluster Setup with Vagrant on CoreOS

## Prerequisites
### Vagrant
Install Vagrant

### Starting the Machines
You can modify the Vagrantfile if you want.

```
$ vagrant up
```

### Testing the Cluster Setup

* Open a browser and type the address of the consul ui for one of the servers (e.g http://172.17.4.51:8500/ui/#/dc1/nodes). You should see 3 consul cluster servers with 2 consul agents (or clients) in the node tab.

#### Starting the containers

* Vagrant SSH to node `w1` and start the corresponding containers

```
$ vagrant ssh w1

$ docker run -d -e SERVICE_NAME=python-app -P oba11/python-app
$ docker run -d -v /etc/environment:/etc/environment:ro -p 80:80 oba11/nginx-proxy-consul
```

* Refresh the consul-ui browser and there should be a new service `python-app`.
* Open a new tab browser and type the address of the `nginx-proxy` url on node `w1` above (e.g http://172.17.4.101 as above).
* Vagrant SSH to node `w2` and start the pyhton-app container

```
$ vagrant ssh w2

$ docker run -d -e SERVICE_NAME=python-app -P oba11/python-app
```

* Hit refresh on the browser multiple times on the `nginx-proxy` url and you should see the content changing

### Once done and verified that service discovery is working, cleanup the environment

```
$ vagrant destroy
```
