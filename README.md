# Inception of Things

A simple introduction to Kubernetes using K3s, K3d, Vagrant, and Argo CD.

## Project structure

- `p1`: two Vagrant machines running a K3s server and agent
- `p2`: one K3s server hosting three applications with Ingress routing
- `p3`: a local K3d cluster managed with Argo CD
- `bonus`: a local GitLab instance used as the Argo CD repository

## Requirements

- Linux virtual machine
- Vagrant and libvirt for `p1` and `p2`
- Docker, kubectl, and K3d for `p3`
- Make

## Usage

### Part 1

```sh
cd p1
vagrant up
vagrant ssh sbandaogS
kubectl get nodes
```

### Part 2

```sh
cd p2
vagrant up
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110
```

The second application runs with three replicas. Requests without a recognized host are routed to the third application.

### Part 3

```sh
cd p3
make install
make setup
make status
make argocd-ui
```

Argo CD is available at <https://localhost:8443> while `make argocd-ui` is running.

### Bonus

```sh
cd bonus
make install
make setup
make credentials
make argocd-gitlab
```

See [`bonus/README.md`](bonus/README.md) for the optional GitLab and Garage commands.

## Cleanup

```sh
cd p1 # or p2
vagrant destroy -f
```

```sh
cd p3 # or bonus
make clean
```
