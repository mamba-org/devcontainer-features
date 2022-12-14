#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

conda_forge_channel_present() {
    micromamba config get channels | grep -q "\- conda-forge$"
}
check "conda-forge channel present" conda_forge_channel_present

reportResults
