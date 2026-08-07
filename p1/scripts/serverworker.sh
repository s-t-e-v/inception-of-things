#!/bin/bash
set -e

SERVER_IP="192.168.56.110"
WORKER_IP="192.168.56.111"

echo "Waiting for node-token from server..."
until curl -sf "http://${SERVER_IP}:8000/node-token" -o /tmp/node-token; do
  sleep 2
done

NODE_TOKEN=$(cat /tmp/node-token)

curl -sfL https://get.k3s.io | K3S_URL="https://${SERVER_IP}:6443" \
  K3S_TOKEN="${NODE_TOKEN}" \
  INSTALL_K3S_EXEC="agent \
  --node-ip=${WORKER_IP} \
  --flannel-iface=eth1" sh -

echo "K3s agent installed and joined the cluster."