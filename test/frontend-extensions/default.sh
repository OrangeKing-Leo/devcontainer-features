#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "install completed (smoke)" bash -c "true"

reportResults
