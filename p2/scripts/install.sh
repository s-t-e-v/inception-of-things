#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/../manifests"

if [[ ${EUID} -ne 0 ]]; then
  echo "Please run this script as root." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y curl
fi

if ! command -v k3s >/dev/null 2>&1; then
  echo "Installing K3s..."
  curl -sfL https://get.k3s.io | sh -
fi

if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-enabled --quiet k3s || ! systemctl is-active --quiet k3s; then
        echo "Configuring K3s..."
        sudo systemctl enable --now k3s
    fi

    if systemctl is-enabled --quiet k3s && systemctl is-active --quiet k3s; then
        echo "K3s is enabled and running."
    else
        echo "ERROR: Failed to configure K3s."
        sudo systemctl status k3s --no-pager
        exit 1
    fi
fi

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

for i in $(seq 1 30); do
  if k3s kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "Applying Kubernetes manifests..."
k3s kubectl apply -f "${MANIFESTS_DIR}/namespace.yaml"
k3s kubectl apply -f "${MANIFESTS_DIR}/app1.yaml"
k3s kubectl apply -f "${MANIFESTS_DIR}/app2.yaml"
k3s kubectl apply -f "${MANIFESTS_DIR}/app3.yaml"
k3s kubectl apply -f "${MANIFESTS_DIR}/ingress.yaml"

echo "Installation complete."
