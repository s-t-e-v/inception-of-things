#!/usr/bin/env bash
set -e

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_dependencies() {
    echo "Installing base dependencies..."

    sudo apt update
    sudo apt install -y ca-certificates curl
}

configure_docker() {
    echo "Configuring Docker..."

    sudo systemctl enable --now docker

    if id -nG "$USER" | grep -qw docker; then
        echo "User '$USER' already belongs to the docker group."
    else
        sudo usermod -aG docker "$USER"

        echo "User '$USER' added to the docker group."
        echo "Reboot or log out completely to activate the new membership."
    fi
}

install_docker() {
    if is_installed docker; then
        echo "Docker is already installed."
    else
        echo "Installing Docker..."

        sudo install -m 0755 -d /etc/apt/keyrings

        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    configure_docker
}

install_kubectl() {
    if is_installed kubectl; then
        echo "kubectl is already installed."
        return 0
    fi

    echo "Installing kubectl..."

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl

    echo "kubectl installed."
}

install_k3d() {
    if is_installed k3d; then
        echo "k3d is already installed."
        return 0
    fi

    echo "Installing k3d..."

    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

    echo "k3d installed."
}

verify_installation() {
    local missing=0

    echo
    echo "Checking installation..."

    for tool in docker kubectl k3d; do
        if is_installed "$tool"; then
            echo "[OK] $tool"
        else
            echo "[MISSING] $tool"
            missing=1
        fi
    done

    if is_installed docker; then
        if docker compose version >/dev/null 2>&1; then
            echo "[OK] docker compose"
        else
            echo "[MISSING] docker compose"
            missing=1
        fi
    fi

    if [ "$missing" -ne 0 ]; then
        return 1
    fi

    if docker info >/dev/null 2>&1; then
        echo "[OK] Docker is accessible without sudo."
    else
        echo "[ERROR] Docker is installed but inaccessible without sudo."
        echo "Current groups: $(id -nG)"
        echo "Log out/reboot if the docker group was just added."
        return 1
    fi

    echo
    docker --version
    docker compose version
    kubectl version --client
    k3d version

    return 0
}

main() {
    echo "Setting up p3 environment..."

    install_dependencies
    install_docker
    install_kubectl
    install_k3d

    verify_installation

    echo
    echo "p3 environment setup complete."
}

case "${1:-}" in
    --check)
        verify_installation
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [--check]" >&2
        exit 2
        ;;
esac