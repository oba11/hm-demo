# Kubernetes Cluster Setup with Vagrant on CoreOS

Please **NOTE** this setup was lifted from `https://github.com/coreos/coreos-kubernetes`

## Prerequisites
### Vagrant
Install Vagrant

### Kubectl
This is the primary tool for administering kubernetes.
Set the ARCH environment variable to **linux** or **darwin** based on your workstation operating system

```
$ ARCH=darwin; wget https://storage.googleapis.com/kubernetes-release/release/v1.0.6/bin/$ARCH/amd64/kubectl
$ chmod +x kubectl
$ mv kubectl /usr/local/bin/kubectl
```

### Starting the Machines
You can modify the Vagrantfile if you want.

```
$ vagrant up
```

### Configure Kubectl

```
$ kubectl config set-cluster vagrant --server=https://172.17.4.101:443 --certificate-authority=${PWD}/ssl/ca.pem
$ kubectl config set-credentials vagrant-admin --certificate-authority=${PWD}/ssl/ca.pem --client-key=${PWD}/ssl/admin-key.pem --client-certificate=${PWD}/ssl/admin.pem
$ kubectl config set-context vagrant --cluster=vagrant --user=vagrant-admin
$ kubectl config use-context vagrant
```

Test that the configuration is right

```
$ kubectl get nodes
NAME           LABELS                                STATUS
172.17.4.201   kubernetes.io/hostname=172.17.4.201   Ready
172.17.4.202   kubernetes.io/hostname=172.17.4.202   Ready
```

### Adding the Kubernetes Components

Submit the Service components

```
$ kubectl create -f components/python-app-service.yaml
```

Submit the ReplicationController components

```
$ kubectl create -f components/python-app-controller.yaml
$ kubectl create -f components/nginx-controller.yaml
```

### Testing the components

* Get the status of the pods and all should be running

```
$ kubectl get pods
NAME               READY     STATUS    RESTARTS   AGE
nginx-rcoe7        1/1       Running   0          5m
python-app-ljiqa   1/1       Running   0          10m

```
* Get the IP address of the nginx pod
```
kubectl get pods -l name=nginx -o wide
NAME          READY     STATUS    RESTARTS   AGE       NODE
nginx-rcoe7   1/1       Running   0          11m       172.17.4.201

```

* Open a browser and type the address of the node above (e.g 172.17.4.201 as above)
* Scale the Python app proxy from 1 replica to 2 replicas

```
$ kubectl scale --replicas=2 replicationcontrollers python-app
```

* Get the pod status again and should look like below

```
$ kubectl get pods
NAME               READY     STATUS    RESTARTS   AGE
nginx-rcoe7        1/1       Running   0          12m
python-app-5afmg   1/1       Running   0          3m
python-app-ljiqa   1/1       Running   0          17m
```

* Hit refresh on the browser multiple times and you should see the content changing

### Once done and verified that service discovery is working, cleanup the environment

```
$ vagrant destroy
```
