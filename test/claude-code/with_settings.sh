#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "claude on PATH"          bash -c "command -v claude"
check "claude --version"        bash -c "claude --version"
check "settings.json created"   bash -c "test -f /home/vscode/.claude/settings.json"

reportResults
