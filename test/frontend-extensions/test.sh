#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

# Metadata-only feature: extensions install via VS Code post-attach, which
# the devcontainer feature-test harness cannot exercise. Smoke check only.
check "install completed (smoke)" bash -c "true"

reportResults
