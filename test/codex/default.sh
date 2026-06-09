#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codex on PATH"             bash -lc "command -v codex"
check "codex --version"           bash -lc "codex --version"
check "node present"              bash -c "command -v node"
check "~/.codex pre-created"      bash -c "test -d /home/vscode/.codex"
check "~/.codex writable by user" bash -c "touch /home/vscode/.codex/.probe && rm /home/vscode/.codex/.probe"
check "codex in user npm prefix"  bash -c "test -x /home/vscode/.npm-global/bin/codex"
check "npmrc has user prefix"     bash -c "grep -q 'prefix=' /home/vscode/.npmrc"

reportResults
