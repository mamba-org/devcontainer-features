#!/usr/bin/env bash

clean_up_apt() {
    rm -rf /var/lib/apt/lists/*
}

require_running_as_root() {
    local error_message="${1:-Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script.}"
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${error_message}"
        exit 1
    fi
}

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}
