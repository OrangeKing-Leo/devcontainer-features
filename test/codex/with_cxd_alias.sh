#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codex on PATH"           bash -c "command -v codex"
check "alias file written"      bash -c "test -f /etc/profile.d/codex-aliases.sh"
check "cxd alias defined"       bash -c "grep -q \"alias cxd='codex --dangerously-bypass-approvals-and-sandbox'\" /etc/profile.d/codex-aliases.sh"
check "bash sources alias file" bash -c "grep -q 'codex-aliases.sh' /etc/bash.bashrc"

reportResults
