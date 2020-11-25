### Install [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Install [Kind](https://github.com/kubernetes-sigs/kind#installation-and-usage)
```
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64"
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
```

### Create a cluster
```
kind create cluster
```

### Wait until Kubernetes Nodes are ready
```
for node in $(kind get nodes); do
    kubectl wait --for=condition=ready "node/$node"
done
```

## Install Multus and CNI plugins to Kind cluster
Start by installing Multus in the cluster:
```
kubectl apply -f https://raw.githubusercontent.com/intel/multus-cni/v3.4.2/images/multus-daemonset.yml
```

Install the CNI binaries:
```
for node in $(kind get nodes); do
    docker exec -it $node bash -c 'curl -fsSL https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz | tar -xz -C /opt/cni/bin/'
done
```

Now you can use CNFs that require Multus and CNIs, e.g. [examples/ip-forwarder](https://github.com/cncf/cnf-conformance/tree/master/example-cnfs/ip-forwarder)