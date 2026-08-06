#!/usr/bin/env bash
set -e

# k3d
k3d cluster create --config "confs/k3d-cluster.yaml"


kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=600s deployment/argocd-applicationset-controller -n argocd

kubectl apply -n argocd -f confs/application.yaml