#!/usr/bin/env bash

set -e

# Move to the same directory as this script
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${FEATURE_DIR}"

# Options
VERSION=${VERSION:-"latest"}
ALLOW_REINSTALL=${ALLOWREINSTALL:-"false"}
IFS=',' read -r -a CHANNELS <<< "$CHANNELS"  # Convert comma-separated list to array
IFS=',' read -r -a PACKAGES <<< "$PACKAGES"  # Convert comma-separated list to array
ENV_FILE=${ENVFILE:-""}
ENV_NAME=${ENVNAME:-""}

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

micromamba_install_as_user() {
    local packages="$*"
    if [ -n "${packages}" ]; then
        echo "Installing packages..."
        micromamba_as_user install --root-prefix="${MAMBA_ROOT_PREFIX}" --prefix="${MAMBA_ROOT_PREFIX}" -y "${packages}"
    fi
}

micromamba_create_as_user() {
    local env_file="$1"
    local env_name="$2"
    local opt="-y -f ${env_file}"

    if [ -n "${env_name}" ]; then
        opt="${opt} -n ${env_name}"
    fi

    micromamba_as_user install --root-prefix="${MAMBA_ROOT_PREFIX}" --prefix="${MAMBA_ROOT_PREFIX}" "${opt}"
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

add_channels() {
    # Channels source: <https://docs.anaconda.com/anaconda/user-guide/tasks/using-repositories/>
    anaconda_channels=("defaults" "main" "r" "msys2" "free" "mro" "mro-archive" "archive" "pro" "anaconda-extras" "anaconda")
    for channel in "${CHANNELS[@]}"; do
        if [ ! -z "${channel}" ]; then
            echo "Adding channel ${channel}"
            micromamba_as_user config append channels "${channel}"
            if [[ " ${anaconda_channels[*]} " =~ " ${channel} " ]]; then
                make_anaconda_repository_warning
            fi
        fi
    done
}

make_anaconda_repository_warning() {
    # Original source:
    # <https://github.com/devcontainers/features/blob/baf47e22b0c3dc5b418ac57aae2e750d14bbc9a3/src/conda/install.sh#L104-L119>

    # Display a notice on conda when not running in GitHub Codespaces
    mkdir -p /usr/local/etc/vscode-dev-containers
    cat << 'EOF' > /usr/local/etc/vscode-dev-containers/conda-notice.txt
When using "micromamba" from outside of GitHub Codespaces, note the Anaconda repository contains
restrictions on commercial use that may impact certain organizations. See https://aka.ms/ghcs-conda
EOF

    notice_script="$(cat << 'EOF'
if [ -t 1 ] && [ "${IGNORE_NOTICE}" != "true" ] && [ "${TERM_PROGRAM}" = "vscode" ] && [ "${CODESPACES}" != "true" ] && [ ! -f "$HOME/.config/vscode-dev-containers/conda-notice-already-displayed" ]; then
    cat "/usr/local/etc/vscode-dev-containers/conda-notice.txt"
    mkdir -p "$HOME/.config/vscode-dev-containers"
    ((sleep 10s; touch "$HOME/.config/vscode-dev-containers/conda-notice-already-displayed") &)
fi
EOF
)"

    if [ -f "/etc/zsh/zshrc" ]; then
        echo "${notice_script}" | tee -a /etc/zsh/zshrc
    fi

    if [ -f "/etc/bash.bashrc" ]; then
        echo "${notice_script}" | tee -a /etc/bash.bashrc
    fi
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

add_channels

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

# shellcheck disable=SC2048 disable=SC2086
micromamba_install_as_user ${PACKAGES[*]}

if [ -f "${ENV_FILE}" ]; then
    echo "Create env by ${ENV_FILE}..."
    micromamba_create_as_user "${ENV_FILE}" "${ENV_NAME}"
fi

micromamba_as_user clean -yaf

clean_up_apt_if_updated

echo "Done!"
