#!/usr/bin/env bash
set -Eeuo pipefail

error_handler() {
    local exit_code=$?
    printf '[ssh] ERROR: command failed (exit %d) at line %d: %s\n' \
        "$exit_code" "$1" "$2" >&2
    exit "$exit_code"
}

trap 'error_handler "$LINENO" "$BASH_COMMAND"' ERR

NAMESPACE="gitlab"
DEPLOYMENT="gitlab-webservice-default"
KEY_PATH="${HOME}/.ssh/id_ed25519"
KEY_TITLE="inception-of-things"
KNOWN_HOSTS_PATH="${HOME}/.ssh/known_hosts"
GITLAB_KNOWN_HOST="[gitlab.localhost]:2222"

if [[ ! -f "$KEY_PATH.pub" ]]; then
    printf '[ssh] Generating %s\n' "$KEY_PATH"
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    ssh-keygen -q -t ed25519 -N "" \
        -C "$(id -un)@inception-of-things" -f "$KEY_PATH"
fi

printf '[ssh] Waiting for the GitLab webservice\n'
kubectl rollout status deployment/$DEPLOYMENT \
    --namespace "$NAMESPACE" --timeout=10m

# k3d recreates the local GitLab host key.
if [[ -f "$KNOWN_HOSTS_PATH" ]]; then
    ssh-keygen -f "$KNOWN_HOSTS_PATH" -R "$GITLAB_KNOWN_HOST" >/dev/null
fi

if ssh -o BatchMode=yes -o ConnectTimeout=5 \
    -o StrictHostKeyChecking=accept-new \
    -T -p 2222 git@gitlab.localhost >/dev/null 2>&1; then
    printf '[ssh] The SSH key is already registered\n'
    exit 0
fi

public_key="$(<"$KEY_PATH.pub")"

printf '[ssh] Registering the public key with the GitLab root account\n'
kubectl exec --namespace "$NAMESPACE" deployment/$DEPLOYMENT \
    --container webservice -- \
    env "SSH_PUBLIC_KEY=$public_key" "SSH_KEY_TITLE=$KEY_TITLE" \
    /srv/gitlab/bin/rails runner '
      user = User.find_by_username!("root")
      key = user.keys.find_or_initialize_by(title: ENV.fetch("SSH_KEY_TITLE"))
      key.key = ENV.fetch("SSH_PUBLIC_KEY")
      key.organization = user.organization
      key.save!
    '

printf '[ssh] SSH key registered. Test it after the cluster port is exposed with:\n'
printf '      ssh -T -p 2222 git@gitlab.localhost\n'
