#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "claude on PATH"   bash -c "command -v claude"
check "claude --version" bash -c "claude --version"
check "node present"     bash -c "command -v node"

reportResults
