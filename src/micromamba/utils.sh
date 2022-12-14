#!/usr/bin/env bash

# In case we need to use apt-get we cannot trust the cache since it might be old.
# To avoid any unnecessary operations, we keep track of the cache state here.
apt_cache_state="unaccessed"
# Other possible values of apt_cache_state are "updated" and "clean".
# If apt-get is never run, then this remains as "unaccessed".
# The only functions which directly modify this state are:
#   - clean_up_apt
#   - apt_get_update
# It is indirectly modified by:
#   - clean_up_apt_if_updated
#   - check_packages
# All apt related invocations should use only these functions.
# If apt-get is required, then the progression is:
#   - "unaccessed"
#   # clean_up_apt
#   - "clean"
#   # apt-get update
#   - "updated"
#   # apt-get install ...  # one or more times, via check_packages
#   # clean_up_apt  # via the clean_up_apt_if_updated function
#   - "clean"
# and then the script exits.

clean_up_apt() {
    rm -rf /var/lib/apt/lists/*
    apt_cache_state="clean"
}

clean_up_apt_if_updated() {
    if [ "${apt_cache_state}" = "updated" ]; then
        clean_up_apt
    fi
}

apt_get_update() {
    if [ "${apt_cache_state}" = "unaccessed" ]; then
        clean_up_apt
    fi
    if [ "${apt_cache_state}" = "clean" ]; then
        echo "Running apt-get update..."
        apt-get update -y
        apt_cache_state="updated"
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

require_running_as_root() {
    local error_message="${1:-Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script.}"
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${error_message}"
        exit 1
    fi
}

# Source:
# <https://github.com/devcontainers/features/blob/7b009e661f13085629b19fc157b577916587f6bc/src/nix/utils.sh#L67-L83>
# If in automatic mode, determine if a user already exists, if not use root
detect_user() {
    local user_variable_name=${1:-username}
    local possible_users=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    if [ "${!user_variable_name}" = "auto" ] || [ "${!user_variable_name}" = "automatic" ]; then
        declare -g ${user_variable_name}=""
        for current_user in ${possible_users[@]}; do
            if id -u "${current_user}" > /dev/null 2>&1; then
                declare -g ${user_variable_name}="${current_user}"
                break
            fi
        done
    fi
    if [ "${!user_variable_name}" = "" ] || [ "${!user_variable_name}" = "none" ] || ! id -u "${!user_variable_name}" > /dev/null 2>&1; then
        declare -g ${user_variable_name}=root
    fi
}

ensure_path_for_login_shells() {
    # Ensure that login shells get the correct path if the user updated the PATH using ENV.
    rm -f /etc/profile.d/00-restore-env.sh
    echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
    chmod +x /etc/profile.d/00-restore-env.sh
}
