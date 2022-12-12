#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

conda_forge() {
    micromamba config get channels | grep -q conda-forge
}
check "conda-forge" conda_forge

reportResults
