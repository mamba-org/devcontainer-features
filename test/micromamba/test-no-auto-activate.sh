#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check_no_env() {
    test -z "$CONDA_DEFAULT_ENV"
    test -z "$CONDA_PREFIX"
}
check "not in conda environment" check_no_env

reportResults
