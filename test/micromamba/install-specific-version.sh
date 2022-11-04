#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "version" micromamba --version | grep "0.27.0"

# Report result
reportResults
