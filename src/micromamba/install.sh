#!/usr/bin/env bash

set -e
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${FEATURE_DIR}"

VERSION=${VERSION:-"latest"}
REINSTALL=${REINSTALL:-"false"}
ADD_CONDA_FORGE=$ADDCONDAFORGE
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

micromamba_destination="/usr/local/bin"

# shellcheck source=./utils.sh
source ./utils.sh

detect_user USERNAME

require_running_as_root

ensure_download_prerequisites() {
    # This is the only place we need to use apt, so we can scope clean_up_apt tightly:
    clean_up_apt
    check_packages curl ca-certificates bzip2
    clean_up_apt
}

download_with_curl() {
    local url=$1
    local destination=$2
    curl -sL "${url}" | tar -xj -C "${destination}" --strip-components=1 bin/micromamba
}

install_micromamba() {
    local version=$1
    local destination=$2
    local arch
    local url
    arch="$(uname -m)"
    if [ "$(uname -m)" = "x86_64" ]; then
        arch="64"
    fi
    url="https://micro.mamba.pm/api/micromamba/linux-${arch}/${version}"

    echo "Installing prerequisites for downloading micromamba..."
    ensure_download_prerequisites
    echo "Downloading micromamba from ${url}..."
    download_with_curl "${url}" "${destination}"
    echo "Micromamba download complete."
}

micromamba_as_user() {
    su "${USERNAME}" bash -c "micromamba $*"
}    

export DEBIAN_FRONTEND=noninteractive

if [ "${REINSTALL}" = "false" ]; then
    if type micromamba > /dev/null 2>&1; then
        echo "Detected existing micromamba: $(micromamba --version)."
        echo "The reinstall argument is false, so not overwriting."
        skip_install="true"
    fi
fi

if [ "${skip_install}" != "true" ]; then
    install_micromamba "${VERSION}" "${micromamba_destination}"
fi

if [ "${ADD_CONDA_FORGE}" = "true" ]; then
    micromamba_as_user config append channels conda-forge
fi
micromamba_as_user config set channel_priority strict
micromamba_as_user shell init --shell=bash
micromamba_as_user shell init --shell=zsh

echo "Done installing micromamba!"
