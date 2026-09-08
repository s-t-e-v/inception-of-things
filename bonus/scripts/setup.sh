#!/usr/bin/env bash
set -e

CLUSTER_NAME="k3d-cluster"
# check if the k3d cluster is running
if ! k3d cluster list "$CLUSTER_NAME" --no-headers >/dev/null 2>&1; then
    echo "Error: k3d cluster '$CLUSTER_NAME' is not running. Please do make -C ../p3 install first."
    exit 1
fi

# create a namespace for gitlab
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

# Provision PostgreSQL, Valkey, and Garage using Helm
# 1. Install CloudNativePG operator
helm repo add cnpg https://github.com/cloudnative-pg/charts
helm repo update
helm upgrade --install cnpg-operator cnpg/cloudnative-pg \
    --namespace gitlab

# 2. kubectl apply postgres-cluster.yaml
kubectl apply -f ../confs/postgres-cluster.yaml

# 3. Wait for PostgreSQL to become ready
kubectl wait --for=condition=Ready pod --all -n gitlab --timeout=600s

# 4. Install/provision Valkey
helm repo add valkey https://github.com/valkey-io/valkey-helm
helm repo update
helm upgrade --install valkey valkey/valkey \
    --namespace gitlab \
    -f ../confs/valkey-values.yaml

# kubectl apply -f ../confs/valkey-values.yaml -n gitlab
# kubectl wait --for=condition=Ready pod --all -n gitlab --timeout=600s

# 5. Install/provision object storage
helm repo add garage https://git.deuxfleurs.fr/Deuxfleurs/garage
helm repo update
helm upgrade --install garage garage/garage \
    --namespace gitlab \
    -f ../confs/garage-values.yaml

# kubectl apply -f ../confs/garage-values.yaml -n gitlab
# kubectl wait --for=condition=Ready pod --all -n gitlab --timeout=600s

# 5.5  Create required secrets

# 6. Install GitLab with Helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
    --namespace gitlab \
    -f ../confs/gitlab-values.yaml

# 7. Point GitLab at the PostgreSQL Service
# apply gitlab configuration
# kubectl apply -f ../confs/gitlab-values.yaml -n gitlab

# configure integration with ArgoCD