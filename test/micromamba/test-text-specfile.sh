#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "specfile" sh -c "cat /tmp/specfile.yml"

eval "$(micromamba shell hook --shell=bash)"

check "activate" micromamba activate testenv

test_julia() {
    julia --version | grep -q "1.6."
}
check "test-julia" test_julia

# Report result
reportResults
