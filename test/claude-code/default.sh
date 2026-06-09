#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "claude on PATH"            bash -lc "command -v claude"
check "claude --version"          bash -lc "claude --version"
check "node present"               bash -c "command -v node"
check "~/.claude pre-created"      bash -c "test -d /home/vscode/.claude"
check "~/.claude writable by user" bash -c "touch /home/vscode/.claude/.probe && rm /home/vscode/.claude/.probe"
check "claude in user npm prefix"  bash -c "test -x /home/vscode/.npm-global/bin/claude"
check "npmrc has user prefix"      bash -c "grep -q 'prefix=' /home/vscode/.npmrc"

reportResults
