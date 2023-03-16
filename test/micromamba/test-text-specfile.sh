#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "specfile" sh -c "cat /tmp/specfile.txt"

# The test scripts run in a non-interactive Bash shell, so ~/.bashrc is not
# sourced.  Therefore, we need to manually install the micromamba shell hook.
# <https://github.com/mamba-org/devcontainer-features/pull/11#issuecomment-1465057342>
eval "$(micromamba shell hook --shell=bash)"

check "activate" micromamba activate testenv

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
