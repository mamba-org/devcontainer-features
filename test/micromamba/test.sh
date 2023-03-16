#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "default (latest) version" micromamba --version

no_conda_forge() {
    micromamba config list | (! grep -q conda-forge)
}
check "no-conda-forge" no_conda_forge

# Report result
reportResults
