#!/usr/bin/env bash

set -e

VERSION=${VERSION:-"latest"}
REINSTALL=${REINSTALL:-"false"}

micromamba_destination="/usr/local/bin"

# shellcheck source=./utils.sh
source ./utils.sh

clean_up_apt

require_running_as_root

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

    check_packages curl ca-certificates bzip2
    echo "Downloading micromamba from ${url}..."
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
