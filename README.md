# Simple Demo of Kubernetes and Consul with Service Discovery

## Python App

Change directory to `python-app` and read the instructions in the **README** on how to get it started.

## Installing Helm Chart with Kind

- Deploy Kind to listen on local port
```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30000
    hostPort: 80
    protocol: TCP
    listenAddress: "127.0.0.1"
  - containerPort: 30001
    hostPort: 443
    protocol: TCP
    listenAddress: "127.0.0.1"
EOF
```

- Deploy istio on kind cluster
```bash
istioctl manifest install --skip-confirmation -f -<<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: default
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: 50m
            memory: 128Mi
    ingressGateways:
    - enabled: true
      k8s:
        hpaSpec:
          maxReplicas: 1
        resources:
          requests:
            cpu: 50m
            memory: 128Mi
        service:
          ports:
          - name: status-port
            port: 15021
            targetPort: 15021
          - name: http2
            port: 80
            targetPort: 8080
            nodePort: 30000
          - name: https
            port: 443
            targetPort: 8443
            nodePort: 30001
      name: istio-ingressgateway
  addonComponents:
    grafana:
      enabled: true
    kiali:
      enabled: true
    prometheus:
      enabled: true
  values:
    gateways:
      istio-ingressgateway:
        type: NodePort
    kiali:
      dashboard:
        auth:
          strategy: anonymous
    pilot:
      traceSampling: 100
    tracing:
      enabled: true
EOF
```