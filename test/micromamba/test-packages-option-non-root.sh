#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

test_wget() {
    wget --version | grep -q "GNU Wget"
}
test_xz() {
    xz --version | grep -q "5.2.8"
}
check "test-wget" test_wget
check "test-xz" test_xz

# Report result
reportResults
