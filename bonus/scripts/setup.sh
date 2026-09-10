#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
P3_DIR="$(cd "$PROJECT_DIR/../p3" && pwd)"
CLUSTER_NAME="k3d-cluster"
GITLAB_CHART_VERSION="10.3.1"

cd "$PROJECT_DIR"
trap 'printf "[setup] Failed at line %s: %s\n" "$LINENO" "$BASH_COMMAND" >&2' ERR

# Part 3 cluster
if ! k3d cluster list "$CLUSTER_NAME" --no-headers >/dev/null 2>&1; then
    echo "k3d cluster '$CLUSTER_NAME' is not running; invoking the p3 setup."
    make -C "$P3_DIR" setup

    if ! k3d cluster list "$CLUSTER_NAME" --no-headers >/dev/null 2>&1; then
        echo "Error: p3 setup did not start k3d cluster '$CLUSTER_NAME'." >&2
        exit 1
    fi
fi

kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

# PostgreSQL
if ! kubectl get secret pgsql-secrets -n gitlab >/dev/null 2>&1; then
    kubectl create secret generic pgsql-secrets \
        --namespace gitlab \
        --from-literal=username=postgres \
        --from-literal=password="$(openssl rand -hex 24)"
fi

helm repo add cnpg https://cloudnative-pg.io/charts/
helm repo update
helm upgrade --install cnpg-operator cnpg/cloudnative-pg \
    --namespace gitlab

kubectl wait --for=condition=Available deployment \
    -l app.kubernetes.io/name=cloudnative-pg \
    -n gitlab --timeout=600s

kubectl apply -f confs/postgres-cluster.yaml

kubectl wait --for=condition=Ready cluster.postgresql.cnpg.io/gitlab-postgres \
    -n gitlab --timeout=600s

POSTGRES_PRIMARY="$(kubectl get cluster.postgresql.cnpg.io gitlab-postgres \
    -n gitlab -o jsonpath='{.status.currentPrimary}')"
kubectl exec -i -n gitlab "$POSTGRES_PRIMARY" -c postgres -- \
    psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
SELECT 'CREATE DATABASE gitlab OWNER postgres'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitlab')\gexec
\connect gitlab
CREATE EXTENSION IF NOT EXISTS amcheck;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gist;
SQL

# Valkey
helm repo add valkey https://valkey.io/valkey-helm/
helm repo update
helm upgrade --install valkey valkey/valkey \
    --namespace gitlab \
    -f confs/valkey-values.yaml \
    --wait --timeout 10m

# Garage object storage
"$PROJECT_DIR/scripts/setup-garage.sh"

# GitLab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
    --namespace gitlab \
    --version "$GITLAB_CHART_VERSION" \
    -f "$PROJECT_DIR/confs/gitlab-values.yaml" \
    --wait --timeout 15m

# SSH access
"$PROJECT_DIR/scripts/setup-ssh.sh"
