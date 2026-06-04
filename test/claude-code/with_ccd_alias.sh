#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "claude on PATH"          bash -c "command -v claude"
check "alias file written"      bash -c "test -f /etc/profile.d/claude-code-aliases.sh"
check "ccd alias defined"       bash -c "grep -q \"alias ccd='claude --dangerously-skip-permissions'\" /etc/profile.d/claude-code-aliases.sh"
check "bash sources alias file" bash -c "grep -q 'claude-code-aliases.sh' /etc/bash.bashrc"

reportResults
