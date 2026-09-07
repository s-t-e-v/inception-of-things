#!/usr/bin/env bash
set -e

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

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

install_helm() {
    if is_installed helm; then
        echo "helm is already installed."
        return 0
    fi

    echo "Installing helm..."

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm -f get_helm.sh

    echo "helm installed."
}

verify_installation() {
    local missing=0

    echo
    echo "Checking installation..."

    for tool in helm; do
        if is_installed helm; then
            echo "[OK] $tool"
        else
            echo "[MISSING] $tool"
            missing=1
        fi
    done

    if [ "$missing" -ne 0 ]; then
        return 1
    fi

    echo
    helm version

    return 0
}

main() {
    echo "Setting up bonus environment..."


    install_dependencies
    install_helm
    verify_installation

    echo
    echo "bonus environment setup complete."
}

main