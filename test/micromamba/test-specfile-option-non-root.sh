#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "specfile" sh -c "cat /tmp/specfile.yml"

eval "$(micromamba shell hook --shell=bash)"

check "activate" micromamba activate testenv

test_python() {
    python --version | grep -q "3.6."
}
check "test-python" test_python

# Report result
reportResults
