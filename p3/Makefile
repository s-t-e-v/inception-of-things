.PHONY: help install setup argocd-ui clean recreate status

help:
	@printf '%s\n' \
		"Usage: make <target>" \
		"" \
		"Available targets:" \
		"  help          Show this help message" \
		"  install       Install dependencies (./scripts/install-dependencies.sh)" \
		"  setup         Run project setup (./scripts/setup.sh)" \
		"  recreate      Recreate the k3d cluster (clean + setup)" \
		"  clean         Delete the k3d cluster (k3d cluster delete k3d-cluster)" \
		"  status        Show Kubernetes cluster and dev namespace status" \
		"  argocd-ui     Port-forward Argocd UI at https://localhost:8443"

install:
	@./scripts/install-dependencies.sh

setup:
	@./scripts/setup.sh

argocd-ui:
	@./scripts/argocd-ui.sh

recreate:
	@make clean
	@make setup

status:
	kubectl get nodes
	kubectl get pods -A -o wide
	kubectl get ingress,services,pods -n dev

clean:
	k3d cluster delete k3d-cluster || true
