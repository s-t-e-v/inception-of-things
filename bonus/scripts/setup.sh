#!/usr/bin/env bash
set -e

CLUSTER_NAME="k3d-cluster"
# check if the k3d cluster is running
if ! k3d cluster list "$CLUSTER_NAME" --no-headers >/dev/null 2>&1; then
    echo "Error: k3d cluster '$CLUSTER_NAME' is not running. Please do make -C ../p3 install first."
    exit 1
fi

# create folders for persistent data
mkdir -p ../data/postgresql
mkdir -p ../data/redis
mkdir -p ../data/minio
mkdir -p ../data/gitaly

mkdir -p ../data/prometheus

# apply persitent volume claims
kubectl apply -f ../confs/pv.yaml

# create a namespace for gitlab
kubectl create namespace gitlab || true

# install gitlab using helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm install gitlab gitlab/gitlab -n gitlab

# configure postgresql, redis, and minio
# ...

# apply gitlab configuration
kubectl apply -f ../confs/gitlab.yaml -n gitlab