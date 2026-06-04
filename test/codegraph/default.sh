#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codegraph on PATH"   bash -c "command -v codegraph"
check "codegraph --version" bash -c "codegraph --version"
check "node present"        bash -c "command -v node"

reportResults
