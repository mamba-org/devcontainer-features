#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check_user_activation() {
    whoami | grep vscode
    groups | grep conda
    echo $MAMBA_ROOT_PREFIX | grep "^/opt/conda$"
    micromamba list | grep wget
    ls -al "/opt/conda/bin"
    micromamba remove -y wget
}
check "checking user activation" check_user_activation

reportResults
