#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

test_python() {
    python -c "print(123 + 456)" | grep -q "579"
}
test_r() {
    R -s -e "cat(123 + 456)" | grep -q "579"
}
check "test-python" test_python
check "test-r" test_r

# Report result
reportResults
