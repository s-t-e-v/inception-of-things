#!/usr/bin/env bash
set -e

echo "Setting up p3 environment..."

install_dependencies() {
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
    if command -v docker >/dev/null 2>&1; then
        echo "Docker is already installed."
        return
    fi

    echo "Installing Docker..."
    # Set up the official repository key
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to APT sources
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    # Install Docker Engine, CLI, and Containerd
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add the current user to the docker group to run Docker without sudo
    configure_docker
}

install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        echo "kubectl is already installed."
        return
    fi

    echo "Installing kubectl..."

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl

    echo "kubectl installed."
}

verify_installation() {
    echo
    echo "Installed tools:"

    docker --version
    docker compose version
    kubectl version --client

    echo
    if docker info >/dev/null 2>&1; then
        echo "Docker is accessible without sudo."
    else
        echo "Docker is installed, but this session cannot access it without sudo."
        echo "Current groups: $(id -nG)"
        echo "Reboot the VM if the docker group was just added."
    fi
}

main() {
    install_dependencies
    install_docker
    install_kubectl
    verify_installation

    echo
    echo "p3 environment setup complete."
}

main