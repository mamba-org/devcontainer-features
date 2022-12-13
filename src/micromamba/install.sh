#!/usr/bin/env bash

set -e
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${FEATURE_DIR}"

# Options
VERSION=${VERSION:-"latest"}
ALLOW_REINSTALL=${ALLOWREINSTALL:-"false"}
ADD_CONDA_FORGE=$ADDCONDAFORGE

# Constants
MAMBA_ROOT_PREFIX="/opt/conda"
micromamba_destination="/usr/local/bin"

# shellcheck source=./utils.sh
source ./utils.sh

# Note: The apt-cache is cleared on-demand.
# Thus we don't need here "rm -rf /var/lib/apt/lists/*".

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
detect_user USERNAME

require_running_as_root

ensure_download_prerequisites() {
    # This is the only place we need to use apt, so we can scope clean_up_apt tightly:
    check_packages curl ca-certificates bzip2
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

run_as_user() {
    su "${USERNAME}" "${@}"
}

micromamba_as_user() {
    run_as_user bash -c "micromamba $*"
}    

add_conda_group() {
    if ! cat /etc/group | grep -e "^conda:" > /dev/null 2>&1; then
        groupadd -r conda
    fi
}

initialize_root_prefix() {
    mkdir -p "${MAMBA_ROOT_PREFIX}/conda-meta"
    touch "${MAMBA_ROOT_PREFIX}/conda-meta/history"
    add_conda_group
    usermod -a -G conda "${USERNAME}"
    chown -R "${USERNAME}:conda" "${MAMBA_ROOT_PREFIX}"
    chmod -R g+r+w "${MAMBA_ROOT_PREFIX}"
    find "${MAMBA_ROOT_PREFIX}" -type d -print0 | xargs -n 1 -0 chmod g+s
}

export DEBIAN_FRONTEND=noninteractive

ensure_path_for_login_shells

if [ "${ALLOW_REINSTALL}" = "false" ]; then
    if type micromamba > /dev/null 2>&1; then
        echo "Detected existing micromamba: $(micromamba --version)."
        echo "The allowReinstall argument is false, so not overwriting."
        skip_install="true"
    fi
fi

if [ "${skip_install}" != "true" ]; then
    install_micromamba "${VERSION}" "${micromamba_destination}"
    echo "Micromamba executable installed."
fi

initialize_root_prefix

if [ "${ADD_CONDA_FORGE}" = "true" ]; then
    echo "Appending 'conda-forge' to channels"
    micromamba_as_user config append channels conda-forge
fi

echo "Setting channel_priority to strict"
micromamba_as_user config set channel_priority strict

echo "Initializing Bash shell"
micromamba_as_user shell init --shell=bash
su -c "if ! grep -q 'micromamba activate # added by micromamba devcontainer feature' ~/.bashrc; then echo 'micromamba activate # added by micromamba devcontainer feature' >> ~/.bashrc; fi" - "${USERNAME}"

if type zsh > /dev/null 2>&1; then
    echo "Initializing zsh shell"
    micromamba_as_user shell init --shell=zsh
    su -c "if ! grep -q 'micromamba activate # added by micromamba devcontainer feature' ~/.zshrc; then echo 'micromamba activate # added by micromamba devcontainer feature' >> ~/.zshrc; fi" - "${USERNAME}"
fi

echo "Micromamba configured."

clean_up_apt_if_updated

echo "Done!"
