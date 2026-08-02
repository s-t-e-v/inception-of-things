#!/bin/sh
apt update & apt install curl -y
curl -sfL https://get.k3s.io | sh
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl