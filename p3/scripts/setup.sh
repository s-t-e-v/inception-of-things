#!/usr/bin/env bash
set -Eeuo pipefail

log() {
	printf '[setup] %s\n' "$1"
}

error_handler() {
	local exit_code=$?
	printf '[setup] ERROR: command failed (exit %d) at line %d: %s\n' \
		"$exit_code" "$1" "$2" >&2
	exit "$exit_code"
}

trap 'error_handler "$LINENO" "$BASH_COMMAND"' ERR

# k3d
CLUSTER_NAME="k3d-cluster"

if ! k3d cluster list --no-headers | awk -v name="$CLUSTER_NAME" '$1 == name { found = 1 } END { exit !found }'; then
	log "Cluster '$CLUSTER_NAME' does not exist; creating it"
	k3d cluster create --config "confs/k3d-cluster.yaml"
else
	log "Cluster '$CLUSTER_NAME' already exists"
fi

log "Creating the argocd namespace"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
log "Installing Argo CD"
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
log "Waiting for Argo CD pods to become ready"
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=600s

log "Applying the Argo CD application"
kubectl apply -n argocd -f confs/application.yaml
log "Setup completed"