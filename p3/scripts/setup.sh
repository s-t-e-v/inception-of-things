#!/usr/bin/env bash
set -e

# k3d
k3d cluster create --config "confs/k3d-cluster.yaml" --wait


kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ? jsonpath {.data.password} ??? how it works ???
# password=$(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
git clone https://github.com/s-t-e-v/argocd-app-sbandaog
cd argocd-app-sbandaog

kubectl apply -f application.yaml