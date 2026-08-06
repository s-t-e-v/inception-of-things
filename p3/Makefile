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