#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_PATH="root/argocd-app-sbandaog"
SOURCE_REPOSITORY="https://github.com/s-t-e-v/argocd-app-sbandaog.git"
TARGET_REPOSITORY="ssh://git@gitlab.localhost:2222/${PROJECT_PATH}.git"
ARGO_REPOSITORY="ssh://git@gitlab-gitlab-shell.gitlab.svc.cluster.local:2222/${PROJECT_PATH}.git"
KEY_PATH="${HOME}/.ssh/id_ed25519"

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

if [[ ! -f "$KEY_PATH" ]]; then
    printf '[repository] Error: SSH key %s is missing; run make ssh-setup first\n' \
        "$KEY_PATH" >&2
    exit 1
fi

remote_refs=""
if remote_refs="$(git ls-remote "$TARGET_REPOSITORY" 2>/dev/null)" && \
    [[ -n "$remote_refs" ]]; then
    printf '[repository] GitLab repository already contains commits; leaving it unchanged\n'
else
    repository_dir="$(mktemp -d)"
    trap 'rm -rf "$repository_dir"' EXIT

    printf '[repository] Cloning %s\n' "$SOURCE_REPOSITORY"
    git clone --bare "$SOURCE_REPOSITORY" "$repository_dir/repository.git"

    printf '[repository] Copying branches and tags to %s\n' "$TARGET_REPOSITORY"
    git -C "$repository_dir/repository.git" push "$TARGET_REPOSITORY" --all
    git -C "$repository_dir/repository.git" push "$TARGET_REPOSITORY" --tags
fi

printf '[repository] Configuring Argo CD access to the GitLab repository\n'
kubectl create secret generic gitlab-repository \
    --namespace argocd \
    --from-literal=type=git \
    --from-literal="url=$ARGO_REPOSITORY" \
    --from-literal=insecure=true \
    --from-file="sshPrivateKey=$KEY_PATH" \
    --dry-run=client --output yaml | kubectl apply -f -
kubectl label secret gitlab-repository \
    --namespace argocd \
    argocd.argoproj.io/secret-type=repository \
    --overwrite
