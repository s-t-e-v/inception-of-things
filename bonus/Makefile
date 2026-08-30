.PHONY: help install setup status fclean

help:
	@printf '%s\n' \
		"Usage: make <target>" \
		"" \
		"Available targets:" \
		"  help          Show this help message" \
		"  install       Install the tools required for bonus (./scripts/install.sh)" \
		"  setup         Run project setup (./scripts/setup.sh)" \
		"  status        Show Kubernetes cluster and dev namespace status"

install:
	@./scripts/install.sh

setup:
	@./scripts/setup.sh

status:
	kubectl get nodes
	kubectl get pods -A -o wide
	kubectl get ingress,services,pods -n dev

fclean:
	@sudo rm -rf ./data