#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

test_reinstall() {
    micromamba --version | grep "1.0.0"
}
check "test-reinstall" test_reinstall

reportResults
