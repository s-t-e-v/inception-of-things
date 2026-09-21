#!/bin/bash

set -e

SERVER_IP="192.168.56.110"

if ! command -v curl >/dev/null 2>&1 || ! command -v ifconfig >/dev/null 2>&1; then
  apt update
  apt install -y curl net-tools
fi

SBIN_PATH_LINE='export PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"'
grep -qxF "$SBIN_PATH_LINE" /home/vagrant/.bashrc || \
  echo "$SBIN_PATH_LINE" >> /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=${SERVER_IP} \
  --bind-address=${SERVER_IP} \
  --advertise-address=${SERVER_IP} \
  --flannel-iface=eth1" sh -

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
sed -i "s/127.0.0.1/${SERVER_IP}/g" /home/vagrant/.kube/config

echo "K3s server installed. Node token:"
echo 'export KUBECONFIG=/home/vagrant/.kube/config' > /etc/profile.d/k3s-kubeconfig.sh
echo "alias k='kubectl'" >> /etc/profile.d/k3s-kubeconfig.sh
chmod +x /etc/profile.d/k3s-kubeconfig.sh
cat /var/lib/rancher/k3s/server/node-token

# Serve the token over the private network instead of /vagrant
mkdir -p /tmp/token-share
cp /var/lib/rancher/k3s/server/node-token /tmp/token-share/node-token
setsid python3 -m http.server 8000 --bind "${SERVER_IP}" --directory /tmp/token-share \
  < /dev/null > /var/log/token-http.log 2>&1 &
disown
