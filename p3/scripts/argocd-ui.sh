#!/usr/bin/env bash
set -Eeuo pipefail

URL="https://localhost:8443"

password="$(kubectl get secret argocd-initial-admin-secret \
    --namespace argocd \
    --output jsonpath='{.data.password}' 2>/dev/null | base64 --decode || true)"

printf 'Argo CD URL: %s\nUsername: admin\n' "$URL"
if [[ -n "$password" ]]; then
    printf 'Password: %s\n' "$password"
else
    printf 'Password: unavailable yet\n'
fi

if curl --insecure --silent --fail --max-time 2 \
    "$URL/api/version" >/dev/null; then
    printf 'Argo CD UI is already running.\n'
    exit 0
fi

if ss -ltnH | awk '$4 ~ /:8443$/ { found = 1 } END { exit !found }'; then
    printf 'Error: port 8443 is already used by another service.\n' >&2
    exit 1
fi

printf 'Starting Argo CD UI port-forward; press Ctrl+C to stop it.\n'
exec kubectl port-forward service/argocd-server \
    --namespace argocd 8443:443
