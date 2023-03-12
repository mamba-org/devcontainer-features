#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "specfile" sh -c "cat /tmp/specfile.txt"

eval "$(micromamba shell hook --shell=bash)"

check "activate" micromamba activate testenv

test_julia() {
    julia --version
}
check "test-julia" test_julia

# Report result
reportResults
