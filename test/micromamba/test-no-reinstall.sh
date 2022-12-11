#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "test-no-reinstall" micromamba --version | grep "0.26.0"

# Report result
reportResults
