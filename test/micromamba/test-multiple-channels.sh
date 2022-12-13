#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

conda_forge_channel_present() {
    micromamba config get channels | grep -q "\- conda-forge$"
}
defaults_channel_present() {
    micromamba config get channels | grep -q "\- defaults$"
}
check "conda-forge channel present" conda_forge_channel_present
check "defaults channel present" defaults_channel_present

reportResults
