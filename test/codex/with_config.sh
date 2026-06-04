#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codex on PATH"        bash -c "command -v codex"
check "codex --version"      bash -c "codex --version"
check "config.toml created"  bash -c "test -f /home/vscode/.codex/config.toml"

reportResults
