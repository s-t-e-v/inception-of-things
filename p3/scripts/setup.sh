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