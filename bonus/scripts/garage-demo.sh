#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_PATH="$PROJECT_DIR/assets/garage-demo.png"
NAMESPACE="gitlab"
PROJECT_PATH="root/garage-lfs-demo"
TARGET_REPOSITORY="ssh://git@gitlab.localhost:2222/${PROJECT_PATH}.git"
KEY_PATH="${HOME}/.ssh/id_ed25519"

demo_dir="$(mktemp -d)"
verify_dir="$(mktemp -d)"
trap 'rm -rf "$demo_dir" "$verify_dir"' EXIT

for tool in git kubectl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf '[garage-demo] Error: %s is not installed\n' "$tool" >&2
        exit 1
    fi
done

if ! git lfs version >/dev/null 2>&1; then
    printf '[garage-demo] Error: git-lfs is missing; run make install first\n' >&2
    exit 1
fi

if [[ ! -f "$ASSET_PATH" ]]; then
    printf '[garage-demo] Error: demo image is missing at %s\n' "$ASSET_PATH" >&2
    exit 1
fi

if [[ ! -f "$KEY_PATH" ]]; then
    printf '[garage-demo] Error: SSH key %s is missing; run make ssh-setup first\n' \
        "$KEY_PATH" >&2
    exit 1
fi

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

printf '[garage-demo] Preparing %s\n' "$PROJECT_PATH"
if git ls-remote "$TARGET_REPOSITORY" >/dev/null 2>&1; then
    git clone "$TARGET_REPOSITORY" "$demo_dir/repository"
else
    git init --initial-branch=main "$demo_dir/repository"
    git -C "$demo_dir/repository" remote add origin "$TARGET_REPOSITORY"
fi
git -C "$demo_dir/repository" lfs install --local
git -C "$demo_dir/repository" lfs track '*.png'
cp "$ASSET_PATH" "$demo_dir/repository/garage-demo.png"
git -C "$demo_dir/repository" add .gitattributes garage-demo.png

if ! git -C "$demo_dir/repository" diff --cached --quiet; then
    git -C "$demo_dir/repository" \
        -c user.name='Garage demo' \
        -c user.email='garage-demo@local.test' \
        commit -m 'Add Garage-backed Git LFS image'
    git -C "$demo_dir/repository" push origin HEAD:main
else
    printf '[garage-demo] The demo image is already up to date\n'
fi

if ! git -C "$demo_dir/repository" show HEAD:garage-demo.png | \
    grep -q '^version https://git-lfs.github.com/spec/v1$'; then
    printf '[garage-demo] Error: repository image is not a Git LFS pointer\n' >&2
    exit 1
fi

printf '[garage-demo] Git LFS object recorded by Git:\n'
git -C "$demo_dir/repository" lfs ls-files

printf '[garage-demo] Fresh-cloning the image through GitLab LFS\n'
git clone --branch main "$TARGET_REPOSITORY" "$verify_dir/repository"
git -C "$verify_dir/repository" lfs install --local
git -C "$verify_dir/repository" lfs pull
cmp "$ASSET_PATH" "$verify_dir/repository/garage-demo.png"

garage_pod="$(kubectl get pod --namespace "$NAMESPACE" \
    --selector app.kubernetes.io/instance=garage \
    --output jsonpath='{.items[0].metadata.name}')"
printf '[garage-demo] Garage bucket statistics:\n'
kubectl exec --namespace "$NAMESPACE" "$garage_pod" -- \
    /garage bucket info git-lfs

printf '[garage-demo] Success: GitLab stored and retrieved garage-demo.png through Garage\n'
