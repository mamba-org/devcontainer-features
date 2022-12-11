#!/usr/bin/env bash

set -e
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${FEATURE_DIR}"

VERSION=${VERSION:-"latest"}
REINSTALL=${REINSTALL:-"false"}
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

micromamba_destination="/usr/local/bin"

# shellcheck source=./utils.sh
source ./utils.sh

detect_user USERNAME

require_running_as_root

download_with_curl() {
    local url=$1
    local destination=$2
    curl -sL "${url}" | tar -xj -C "${destination}" --strip-components=1 bin/micromamba
}

ensure_download_prerequisites() {
    # This is the only place we need to use apt, so we can scope clean_up_apt tightly:
    clean_up_apt
    check_packages curl ca-certificates bzip2
    clean_up_apt
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

    echo "Downloading micromamba from ${url}..."
    ensure_download_prerequisites
    download_with_curl "${url}" "${destination}"
}

export DEBIAN_FRONTEND=noninteractive

if [ "${REINSTALL}" = "false" ]; then
    if type micromamba > /dev/null 2>&1; then
        echo "Detected existing micromamba: $(micromamba --version)."
        echo "The reinstall argument is false, so not overwriting."
        exit 0
    fi
fi

install_micromamba "${VERSION}" "${micromamba_destination}"

clean_up_apt

echo "Done!"
