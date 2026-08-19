# K3d and Argo CD

## Why bothering with all of this in the first place?

You might want to build a web application, a very complex one, that depends on many things to run. Like Youtube, Amazon, you name it.

You want it to be as reliable, resilient, self-healing and available all the time as much as possible. If you don't commit to this standards, you'll soon have big troubles, as your web app would crash, making your client drop your app. You'll lose a lot of money. And that's a case scenario, not the worst.it could be much more dramatic as the service is critical for your clients or the society.

To achieve this goal, we often want to adopt the following strategy: splitting the whole app features into smaller self-contained and independant app as much as possible

Consider this imagery: you are in a restaurant, about to eat a bolognese pasta plate. In this plate, ingredients are mixed up. It is very tasty, however, if one ingredient is bad, it is very difficult to enjoy the whole plate, you might just leave the restaurant. Now, let's say you chose to eat a steak - fries with vegetable plate. Let's imagine this day fries are awfull. You can still enjoy steak and vegetables for the time being, waiting for the fries to be replaced. You can bear the inconvenience much more, and it easier for the restaurant to fix the plate.

Likewise, if you build a complex web app, when things are getting serious with your web app, you don't want the pasta bolognese failure scenario to happen, you would prefer the steak - fries one. It is better for the customer and better for you. You would prefer for your web app what we called a microsevice architecture, meaning each service is self-contained, can exist on its own, if it fails, it doesn't render the whole infrastructure, your whole web app necessarly down. You can recover quickly. That's one of the benefit of such software architecture choice, they are many more.

## How do we implement this?

One brutal way would be to but a lot of computers and dedicate one computer to one service. Could work, but it is not practical at all.

To implement a microsevice architecture, the most use solution is a container solution such as docker or podman.

What is a container? It is a process running in a predefined environment, we have all tools, dependencies that it needs. It is a perfect infrastructure for our mircroservice problem, because you can make those container / process servers, meaning they can perform whatever task you expect it to do, and it is easy to reproduce.

You can have multiple containers interacting with each other, so you can achieve your cool super web app. But docker (let's refer to docker for container application in general) alone is not enough, it can be tricky to handle your network of containers, microservices at scales, orchestrate them. In fact, in general, containers are spread accross multiple datacenters, physical servers running them. at region or global level. We'll see how to adress this probelm.

Another solution to implement microsevice would be to spawn multiple virtual machines. They are programs that emulates an entire OS. You can have multiple ones a physical machine if you want. You can achieve almost the same result as docker, it is even more powerful than docker container, howver they are slower to install, setup, launch. So, in general we prefer not to use them to hold one microsevice, but many. We often put many containers inside a VM.

## VMs, containers, which one to chose?

As you might guess from the last paragraph, often we choose both, as chosing both may increase complexity but increase by a lot degree of freedom, flexibility in term of architecture design.

What is commonly done is, instead of having multiple physical servers in your company premises, that costs a lot and maybe overkill for you and might not be able to handle a sudden growth in term of demand if you app becomes very popular, we request services of Cloud providers such as AWS, Google Cloud or Azure. These giants have massive datacenters, a lot of physical servers, distrubuted across the globe, that you can rent on demand. Thanks to virtual machines, you can configure the machine you want quite specifically (the RAM, number of CPUs, etc.). you can span multiple ones and then have your containers distrubetes across the different VMs.

Why doing this? We could simply have 1 VM with all of our containers inside? Well, again, the issue is that to have a reliable system, you need redundancy. Meaning having multiple service doing the same exact thing. In the case one service fails, immediately another one can take over.

You can imagine that it may become to much for a computer or a VM to handle such a high number of replicas inside. Even if a machine could. What if the machine itself crashes? You are again in big trouble. This is where you need to have multiple virtual machines. Again, for redundancy sake.
There is also the problematic of latency, you may simplay ahve no choice but to have virtual machines spread across the glob so that they can be as close as possible to the customer.
To end on why bothering having multiple vms or containers, you have to consider spike of demand. You may not necessarly needs at all time hundres of containers or tens or more VMs at all time. At some time, there is low usage, at some, very high. Being able to create VMS or containers on demand is a must, so you can optimize cost and be very dynamic on client demand. This is part of what we call load balancing.

## Great that sounds awesome, but how does it work?

Indeed, all of this doesn't happen by magic, you need something to orchestrate:

- creations of multiple VMs and containers
- making them communicate across multiple machines distrubted over different regions of the globe
- being able to spawn and destroy on demand

As said earlier, docker-compose or equivalent is not enough to handle multiple containers distrubuted like that.

As for VMs, ??? (I don't know how they are created, destroy, I don't think vagrant are enough, I guess that's something handled at cloud providers level)

For conatainers, the solution to orchestrate all the containers in such architecture is Kubernetes. This is a super orchestrator of containers.

## Kubernetes

How kurbunetes work?

The goal is basically to setup what we call a cluster, essentially a cluser of containers.

A cluster is composed of several nodes.

Nodes are is basically a pack / a cluster of container of containers.

There are two type of nodes:

- server nodes: generally limited to 1 - 2, sometimes, they are "lightwieght" clusters of containers generally dedicated to work fullfill the goal of orchestration of all nodes, such as for example keeping tracking on running containers, nodes, etc. We refer it as Control Panel
- agents nodes: these are nodes that are generally heavy, it contains containers, services doing the actual job, heavy lifting, serving your web app. We can many of these nodes, sometimes they are completely differentm sometimes they are replicates of an orignal agent node. It depends of the redundancy strategy.

[DIAGRAM: server nodes connected to agent nodes]

All of these nodes can be spread across many virtual marchines, kubernetes enables to handle this, which is huge.

An importabt thing to have in mind:
By default, Kubernetes itself place the containers whereever it feels it is the most adapted. You can explicitly try to control this, but you should know what you are doing. applications that are heavy we'll very likely be dispached into agent nodes. You have to see nodes an infrastructure rather than a something you decide expliclty what would it contain. See it like a fluid in a container, you provide the frame, the liquid decide where each molecules set itselves.

To be more accurate, we don't use the term of containers in kubernetes, but more the term of pods, which is an abstraction above containers, as you might chose to use something other than docker containers.

Kubernetess is heavy, it's a huge application. When you develop, you don't want ncessearly to handle gigabytes of application data, etc. You may reserve this when you really have no choice or you have a web app already running that demands full capacity. We call this version k8s.

What we use in this part is the version k3s. A Much lighter version that does almost all what you want. It is great for development and can handle fine most architecture in production as long as it is not too heavy.

To setup a kubernetes cluster, you need, after installing it of course, to configure that clusters via configuration files, written generally in yaml format.

You'll define mainly three things:

- How do you configure you services running in pods (Environment variables, credentials, etc.). It is defined in what we call configMap
- How do you deploy your services: how can we  ???, how many replicas. this is define in what we call Deployment files
- How the services is created: how do you communicate with it inside the cluster, how are you supposed to reach from outside the kuberbetes cluster, and most importantly how do you create the service in the first place, maybe from a docker image. This is define in Service File.

To add on the service case, we ofetn use what we call an Ingress, which is a layer that handles routing request from external clients to the nodes which contains the service itself and maybe other services. indeed, a node can contain several services.

- you can also how it is connected to database (statefull set) [Out of Scope]

## Great let's create VMs and kubernetes

You might if you want, but if you are still in development, you may want to spare yourself from inflecting the chore of seting up vms, turning them of if something go wrong, etc. VMs had quite a lot of frictions during developemt. And this where comes k3d.

## k3d

k3d is a wrapper of k3s, which is basically a docker container, not a vm and that's key. This is what we want, we want to test stuff, iterate rapidly, containers are fast compare to vm to start or restart.

k3d is a container serving k3s. See it like a VM containing k3s, but is a container. inside you cand whatever you are used to with k3s.

k3d comes with a set of commands you can execute from outside the container so it is easier for you to interact with the k3s cluster inside.

With all of this, we almost all it takes to implemt the infrastructure of the subject.

[Image of the infrastructure]

It is a k3s cluster containing a wep app pulled from docker hub which is supposed to be insde a k3d cluster. the pod should be accssible from outside the cluster, meaning we should be able to do http request, curl, etc. But as you can see, there is one thing in this diagram we didn't adress yet: Github. Why is it here, expected, why do we see git / github involve, why do we see sync and push?

## Gitops

When using kubernetes, you might have to change the configuration files, update them. You could locally manage all of this, but it can start to be very tedious, unstable. And people having their own config might get into conflicts with each other real quick. This is where git comes into place. The idea is to dedicate a repo to the configuration. It would be the only source of truth to deploy your cluster, which make maintenance where more easier. We often refer to this as code as infrastructure.

People try to automate things as much as possible, meaning a change in the config repo should automatically update the whole infrastructure. Welcome to the universe of CI, aka Continuous Integration. This concept is not new, so people try to apply that to the idea of git repo as infr is in sync with the git repo. When this is not the case, the middleware has the responsibility to pull the changes. Argocd is that middleware.

## Argocd

Argocd is bascially a service part of the kubernetes cluster. It reguarly poll the git repository for changes. By default, it does it every 3 minutes. 

[??? I don't know by which mechanism argocd is able to detect the change, and most importantly how does it apply the changes]


Now that we have all the notions, let's study how the infrastructure of p3 was setup. Here is a tree view of the main repository for p3:

```
.
├── p3
│   ├── confs
│   │   ├── application.yaml
│   │   └── k3d-cluster.yaml
│   ├── docs
│   │   └── explanation.md
│   ├── Makefile
│   └── scripts
│       ├── install.sh
│       └── setup.sh
└── README.md
```

What will interest us the most is the Makefile, what is inside `confs` and `scripts`.

The makefile is for convenience, to launch scripts and do cleanups, every thing you might want to do in one place.

```Makefile
.PHONY: help install setup argocd-ui clean recreate status

help:
	@printf '%s\n' \
		"Usage: make <target>" \
		"" \
		"Available targets:" \
		"  help          Show this help message" \
		"  install       Install the tools required for p3 (./scripts/install.sh)" \
		"  setup         Run project setup (./scripts/setup.sh)" \
		"  recreate      Recreate the k3d cluster (clean + setup)" \
		"  clean         Delete the k3d cluster (k3d cluster delete k3d-cluster)" \
		"  status        Show Kubernetes cluster and dev namespace status" \
		"  argocd-ui     Port-forward Argocd UI at https://localhost:8443"

install:
	@./scripts/install.sh

setup:
	@./scripts/setup.sh

argocd-ui:
	@password=$$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' 2>/dev/null | base64 -d); \
	if [ -n "$$password" ]; then \
		printf 'Argocd initial admin password: %s\n' "$$password"; \
	else \
		printf 'Argocd initial admin password: unavailable yet\n'; \
	fi
	kubectl port-forward svc/argocd-server -n argocd 8443:443

recreate:
	@make clean
	@make setup

status:
	kubectl get nodes
	kubectl get pods -A -o wide
	kubectl get ingress,services,pods -n dev

clean:
	k3d cluster delete k3d-cluster || true
```

To setup the cluster, we need to install first it's dependencies. This is the job of `make install`, which calls the `install.sh` script. This script installs `curl` if it doesn't exist, `docker` because it is necessary for `k3d` since it is a container, then `k3d`.

Once k3d is installed, we need a script to create and setup our cluster. This is the job of `make setup` which calls the `setup.sh` script:

```bash
#!/usr/bin/env bash
set -e

# k3d
CLUSTER_NAME="k3d-cluster"

if ! k3d cluster list "$CLUSTER_NAME" --no-headers >/dev/null 2>&1; then
	k3d cluster create --config "confs/k3d-cluster.yaml"
fi


kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=600s

kubectl apply -n argocd -f confs/application.yaml
```

We begin with the first command which create the cluster according to the yaml config. We'll focus on this later. Then, as demanded in the subject, we create a namespace for argocd. A namespace is a label that you attached to pods within your cluster so that you can refer to it more easily, by thematic, domain, etc.
Then, we deploy the argocd service via their githun raw.
Finally, we use the other yaml config under `confs/` to setup our argocd service. Setting up here means linking the git repo containing the config file of our kurbunetes infrastructure to argocd. We'll study this config as well, but let's review the k3d yaml config:


```yaml

apiVersion: k3d.io/v1alpha5
kind: Simple # internally, we also have a Cluster config, which is not yet available externally
metadata:
  name: k3d-cluster # name that you want to give to your cluster (will still be prefixed with `k3d-`)
servers: 1
agents: 1
kubeAPI: # same as `--api-port myhost.my.domain:6445` (where the name would resolve to 127.0.0.1)
  hostIP: "127.0.0.1" # where the Kubernetes API will be listening on
  hostPort: "6445" # where the Kubernetes API listening port will be mapped to on your host system
image: rancher/k3s:v1.35.2-k3s1
ports:
  - port: 8888:80
    nodeFilters:
      - loadbalancer
options:
  k3d:
    wait: true # wait for cluster to be usable before returning; same as `--wait` (default: true)
    timeout: "60s" # wait timeout before aborting; same as `--timeout 60s`
  kubeconfig:
    updateDefaultKubeconfig: true # add new cluster to your default Kubeconfig; same as `--kubeconfig-update-default` (default: true)
    switchCurrentContext: true # also set current-context to the new cluster's context; same as `--kubeconfig-switch-context` (default: true)
```


The most important par of this config is `ports`. This is what we'll enable the user in the host machine to communicate with the app within the cluster. We set a port fowarding `8888:80`, 8888 corresponds to the app port, and 80 is the port related to the load balancer. The load balancer [???]. This is the "primary router".

I chose 1 server and 1 agent, but since the infrastructure is pretty light, I could have just use 1 server.

Now, let's focus on the config file responsible to setup argocd according to our need:

```yaml

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-app-sbandaog
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/s-t-e-v/argocd-app-sbandaog
    targetRevision: HEAD
    path: dev
  destination:
    server: https://kubernetes.default.svc
    namespace: dev

  syncPolicy:
    syncOptions:
      - CreateNamespace=true

    automated:
      selfHeal: true
      prune: true
```

as you can see, in spec/source I provided the link to the git repo, targeting the HEAD. I also targeted the dev folder inside the repo, because it contains all the configuration files. The destination spec/destination points to the cluster itself, and we specify the namespace so that anything added from the git repo config file would be under that namespace. We chose `dev` as asked in the subject.

The remaining element from this whole infrastucture is the actual git repo. Here is how it is structured:

```
├── dev
│   ├── deployment.yaml
│   ├── ingress.yaml
│   └── service.yaml
└── README.md
```

The service is built from a docker image, pulled via the deployment config:


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  labels:
    app: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: wil42/playground:v2
        ports:
        - containerPort: 8888
```

It is configured with port 8888 as instructed by the author of the docker image.

We need to setup an ingress controller so that the loadbalancer can find our service within the cluster. The ingress controller help setting up a sytem of fixed ip address, so that if the service pod dies, then respawn, we still point to this service, we don't have to assign manually the new true ip adress within the cluser.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 8888
```

Then we configure the service via the service config file:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: app
  ports:
    - protocol: TCP
      port: 8888
      targetPort: 8888
```

Quite straighforward, this is an issue of setting the port (8888) correctly [??? I don't remember the difference between port and targetPort]

Throughout all the 3 config giles, one thing very important to do correctly is choosing the same label to designate the app. Here it is `app` simply. Then to point to the app, you must use `selector` and use mathcLabels in deployment so it knows which pod to use [??? not sure of what I am taling about]. Same for the service config which can target the deployed app thanks to selector and setting it up. The ingress config only to know the name of the service ass a whole to target it [???? confused how we need to target app-service instead of app. Confused about the metadata, etc.]




Now we are all setup. If you were to change the version of the app docker image and push the change in the git repo, argocd will soon update the infrasture according to that change. The app will change to the version specified in the git repo.
