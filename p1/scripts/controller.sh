#!/usr/bin/env bash
if ! command -v curl >/dev/null 2>&1; then
    apt update
    apt install curl -y
fi

if ! command -v k3s >/dev/null 2>&1; then
    echo "Installing K3s..."

    curl -sfL https://get.k3s.io | sh -

    if command -v k3s >/dev/null 2>&1; then
        echo "K3s installed successfully."
    else
        echo "ERROR: K3s installation failed."
        exit 1
    fi
else
    echo "K3s is already installed."
fi
