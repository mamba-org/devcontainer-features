#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "default (latest) version" micromamba --version

no_conda_forge() {
    micromamba config list | (! grep -q conda-forge)
}
check "no-conda-forge" no_conda_forge

micromamba install --yes --channel=conda-forge python

test_python() {
    python -c "print(123 + 456)" | grep -q "579"
}
check "test-python" test_python

# Report result
reportResults
