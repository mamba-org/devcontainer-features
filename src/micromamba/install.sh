#!/usr/bin/env bash

VERSION=${VERSION:-"latest"}
# Add destination parameter here?

# # This looks like it's not needed:
# USERNAME=${USERNAME:-"automatic"}

set -e

# Is this the standard for dev-container features? It seems like this way each
# feature will rerun `apt-get update` which seems inefficient. But I suppose
# this is to prioritize reliability?
# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    # Or it could install at the user level?
    exit 1
fi

# Do we really need this check? Other architectures are theoretically suppored, namely ppc64le.
# Also, should we be using `uname` instead of `dpkg`?
architecture="$(dpkg --print-architecture)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "arm64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# # This looks like it's not needed:
# # Determine the appropriate non-root user
# if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
#     USERNAME=""
#     POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
#     for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
#         if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
#             USERNAME=${CURRENT_USER}
#             break
#         fi
#     done
#     if [ "${USERNAME}" = "" ]; then
#         USERNAME=root
#     fi
# elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} >/dev/null 2>&1; then
#     USERNAME=root
# fi

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

# # I don't think we should use Git. (See next comment.)
# check_git() {
#     if [ ! -x "$(command -v git)" ]; then
#         check_packages git
#     fi
# }

# # This approach is unfortunately seriously flawed. The reason is that micromamba
# # is compiled by Conda-Forge and published on anaconda.org. The website
# # <https://micro.mamba.pm> actually redirects to anaconda.org for the actual download.
# # There is often several days of delay between when a new version of micromamba is
# # published on GitHub and when it is available on anaconda.org. During this time,
# # the download will be missing, and this procedure will fail.
# find_version_from_git_tags() {
#     local variable_name=$1
#     local requested_version=${!variable_name}
#     if [ "${requested_version}" = "none" ]; then return; fi
#     local repository=$2
#     local prefix=${3:-"tags/v"}
#     local separator=${4:-"."}
#     local last_part_optional=${5:-"false"}
#     if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
#         local escaped_separator=${separator//./\\.}
#         local last_part
#         if [ "${last_part_optional}" = "true" ]; then
#             last_part="(${escaped_separator}[0-9]+)*?"
#         else
#             last_part="${escaped_separator}[0-9]+"
#         fi
#         local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
#         local version_list
#         check_git
#         check_packages ca-certificates
#         version_list="$(git ls-remote --tags "${repository}" | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
#         if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
#             declare -g "${variable_name}"="$(echo "${version_list}" | head -n 1)"
#         else
#             set +e
#             declare -g "${variable_name}"="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
#             set -e
#         fi
#     fi
#     if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" >/dev/null 2>&1; then
#         echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
#         exit 1
#     fi
#     echo "${variable_name}=${!variable_name}"
# }

install_micromamba() {
    local version=$1
    local arch
    local url
    arch="$(uname -m)"
    if [ "$(uname -m)" = "x86_64" ]; then
        arch="64"
    fi
    url="https://micro.mamba.pm/api/micromamba/linux-${arch}/${version}"

    check_packages curl ca-certificates bzip2
    echo "Downloading micromamba from ${url}..."
    curl -sL "${url}" | tar -xj -C /usr/local/bin/ --strip-components=1 bin/micromamba
}

export DEBIAN_FRONTEND=noninteractive

# # Soft version matching
# find_version_from_git_tags VERSION "https://github.com/mamba-org/mamba" "tags/micromamba-"

install_micromamba "${VERSION}"

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
