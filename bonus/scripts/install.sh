#!/usr/bin/env bash
set -e

install_dependencies() {
    local p3_install_script

    p3_install_script="../p3/scripts/install.sh"

    if ! "$p3_install_script" --check; then
        if ! "$p3_install_script"; then
            echo "Error: Failed to install p3 environment. Please check the logs above for details."
            exit 1
        fi
    fi
}

install_postgresql() {
    :
}

install_redis() {
    :
}

install_minio() {
    :
}

install_helm() {
    :
}

verify_installation() {
    echo
    echo "Installed tools:"

    # docker --version
    # docker compose version
    # kubectl version --client
    # k3d version

    # echo
    # if docker info >/dev/null 2>&1; then
    #     echo "Docker is accessible without sudo."
    # else
    #     echo "Docker is installed, but this session cannot access it without sudo."
    #     echo "Current groups: $(id -nG)"
    #     echo "Reboot the VM if the docker group was just added."
    # fi
}

main() {
    echo "Setting up bonus environment..."


    install_dependencies
    install_postgresql
    install_redis
    install_minio
    verify_installation

    echo
    echo "bonus environment setup complete."
}

main