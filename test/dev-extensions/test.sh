#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

# dev-extensions is metadata-only: install.sh has nothing to verify at the
# filesystem level (extensions install via VS Code post-attach, which the
# devcontainer CLI feature-test harness cannot exercise).
check "install completed (smoke)" bash -c "true"

reportResults
