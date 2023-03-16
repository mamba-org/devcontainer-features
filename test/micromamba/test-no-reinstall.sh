#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

test_no_reinstall() {
    micromamba --version | grep "1.2.0"
}
check "test-no-reinstall" test_no_reinstall

reportResults
