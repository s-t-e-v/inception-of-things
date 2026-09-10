.PHONY: help install setup recreate ssh-setup repository garage-demo argocd-ui argocd-gitlab argocd-github status credentials clean

help:
	@printf '%s\n' \
		"Usage: make <target>" \
		"" \
		"Available targets:" \
		"  help          Show this help message" \
		"  install       Install dependencies (./scripts/install-dependencies.sh)" \
		"  setup         Run project setup (./scripts/setup.sh)" \
		"  recreate      Recreate the k3d cluster (clean + setup)" \
		"  ssh-setup     Register this VM user's SSH key with GitLab" \
		"  repository    Copy the GitHub configuration repository to GitLab" \
		"  garage-demo   Push an image with Git LFS and verify Garage storage" \
		"  argocd-ui     Port-forward Argo CD UI at https://localhost:8443" \
		"  argocd-gitlab Copy the repository and switch Argo CD to GitLab" \
		"  argocd-github Restore Argo CD's original GitHub source" \
		"  credentials   Show the initial GitLab root credentials" \
		"  status        Show Kubernetes cluster and dev namespace status" \
		"  clean         Delete the k3d cluster"

install:
	@./scripts/install-dependencies.sh

setup:
	@./scripts/setup.sh

recreate:
	@$(MAKE) clean
	@$(MAKE) setup

ssh-setup:
	@./scripts/setup-ssh.sh

repository: ssh-setup
	@./scripts/copy-repository.sh

garage-demo:
	@./scripts/garage-demo.sh

argocd-ui:
	@$(MAKE) -C ../p3 argocd-ui

argocd-gitlab: repository
	@kubectl apply -f confs/application.yaml

argocd-github:
	@kubectl apply -f ../p3/confs/application.yaml

credentials:
	@password=$$(kubectl get secret gitlab-gitlab-initial-root-password \
		--namespace gitlab \
		--output jsonpath='{.data.password}' 2>/dev/null | base64 --decode); \
	if [ -z "$$password" ]; then \
		printf '%s\n' "Error: GitLab's initial root password is not available yet." >&2; \
		exit 1; \
	fi; \
	printf 'Username: root\nPassword: %s\n' "$$password"

status:
	kubectl get nodes
	kubectl get pods -A -o wide
	kubectl get ingress,services,pods -n dev
	kubectl get applications.argoproj.io -n argocd

clean:
	make -C ../p3 clean
