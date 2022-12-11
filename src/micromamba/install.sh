#!/usr/bin/env bash

VERSION=${VERSION:-"latest"}

micromamba_destination="/usr/local/bin"

set -e

# shellcheck source=./utils.sh
source ./utils.sh

clean_up_apt

require_running_as_root

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
    curl -sL "${url}" | tar -xj -C "${destination}" --strip-components=1 bin/micromamba
}

export DEBIAN_FRONTEND=noninteractive

install_micromamba "${VERSION}" "${micromamba_destination}"

clean_up_apt

echo "Done!"
