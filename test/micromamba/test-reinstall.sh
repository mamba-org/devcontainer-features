#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "test-reinstall" micromamba --version | grep "1.0.0"

# Report result
reportResults
