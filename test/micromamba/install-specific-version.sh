#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

specific_version() {
    micromamba --version | grep "0.27.0"
}
check "specific version" specific_version

reportResults
