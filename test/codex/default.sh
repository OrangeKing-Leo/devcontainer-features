#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codex on PATH"            bash -c "command -v codex"
check "codex --version"          bash -c "codex --version"
check "node present"             bash -c "command -v node"
check "~/.codex pre-created"     bash -c "test -d /home/vscode/.codex"
check "~/.codex owned by vscode" bash -c "[ \"\$(stat -c '%U' /home/vscode/.codex)\" = vscode ]"

reportResults
