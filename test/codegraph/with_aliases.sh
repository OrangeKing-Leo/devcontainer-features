#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "codegraph on PATH"       bash -c "command -v codegraph"
check "alias file written"      bash -c "test -f /etc/profile.d/codegraph-aliases.sh"
check "cgi alias defined"       bash -c "grep -q \"alias cgi='codegraph install'\" /etc/profile.d/codegraph-aliases.sh"
check "cgii alias defined"      bash -c "grep -q \"alias cgii='codegraph init -i'\" /etc/profile.d/codegraph-aliases.sh"
check "bash sources alias file" bash -c "grep -q 'codegraph-aliases.sh' /etc/bash.bashrc"

reportResults
