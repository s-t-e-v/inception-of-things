#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="gitlab"
GARAGE_VERSION="v2.4.1"
GARAGE_KEY_NAME="gitlab-lfs"
GARAGE_BUCKET_NAME="git-lfs"
GARAGE_VALUES_FILE="$PROJECT_DIR/confs/garage-values.yaml"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

printf '[garage] Installing Garage %s\n' "$GARAGE_VERSION"
git clone --branch "$GARAGE_VERSION" --depth 1 \
    https://git.deuxfleurs.fr/Deuxfleurs/garage "$work_dir/garage"

helm upgrade --install garage "$work_dir/garage/script/helm/garage" \
    --namespace "$NAMESPACE" \
    --values "$GARAGE_VALUES_FILE" \
    --wait --timeout 10m

garage_pod="$(kubectl get pod --namespace "$NAMESPACE" \
    --selector app.kubernetes.io/instance=garage \
    --output jsonpath='{.items[0].metadata.name}')"

garage_cli() {
    kubectl exec --namespace "$NAMESPACE" "$garage_pod" -- /garage "$@"
}

garage_status="$(garage_cli status)"
if grep -q 'NO ROLE ASSIGNED' <<<"$garage_status"; then
    node_id="$(awk -v pod="$garage_pod" '$2 == pod { print $1; exit }' \
        <<<"$garage_status")"
    if [[ -z "$node_id" ]]; then
        printf '[garage] Error: could not determine the Garage node ID\n' >&2
        exit 1
    fi

    layout_version="$(garage_cli layout show | awk \
        '/Current cluster layout version:/ { print $5 }')"
    garage_cli layout assign --zone gitlab --capacity 1GB "$node_id"
    garage_cli layout apply --version "$((layout_version + 1))"
fi

if ! garage_cli bucket info "$GARAGE_BUCKET_NAME" >/dev/null 2>&1; then
    garage_cli bucket create "$GARAGE_BUCKET_NAME"
fi

if ! garage_cli key info "$GARAGE_KEY_NAME" >/dev/null 2>&1; then
    garage_cli key create "$GARAGE_KEY_NAME" >/dev/null
fi

garage_cli bucket allow --read --write \
    --key "$GARAGE_KEY_NAME" "$GARAGE_BUCKET_NAME"

key_info="$(garage_cli key info --show-secret "$GARAGE_KEY_NAME")"
access_key="$(awk '/Key ID:/ { print $3 }' <<<"$key_info")"
secret_key="$(awk '/Secret key:/ { print $3 }' <<<"$key_info")"
if [[ -z "$access_key" || -z "$secret_key" ]]; then
    printf '[garage] Error: could not read the Garage access credentials\n' >&2
    exit 1
fi

connection_file="$work_dir/object-storage.yaml"
cat >"$connection_file" <<EOF
provider: AWS
region: garage
aws_access_key_id: $access_key
aws_secret_access_key: $secret_key
endpoint: "http://garage.$NAMESPACE.svc.cluster.local:3900"
path_style: true
EOF
chmod 600 "$connection_file"

kubectl create secret generic gitlab-object-storage \
    --namespace "$NAMESPACE" \
    --from-file="config=$connection_file" \
    --dry-run=client --output yaml | kubectl apply -f -

printf '[garage] Garage is ready for GitLab LFS\n'
