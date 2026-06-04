#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "GIT_ASKPASS blanks askpass"   bash -c "[ \"\$GIT_ASKPASS\" = /bin/false ]"
check "GH_TOKEN cleared"              bash -c "[ -z \"\$GH_TOKEN\" ]"
check "AWS_SECRET cleared"            bash -c "[ -z \"\$AWS_SECRET_ACCESS_KEY\" ]"
check "KUBECONFIG cleared"            bash -c "[ -z \"\$KUBECONFIG\" ]"
check "GIT_TERMINAL_PROMPT=0"         bash -c "[ \"\$GIT_TERMINAL_PROMPT\" = 0 ]"
check "profile.d script written"      bash -c "test -f /etc/profile.d/99-harden-sandbox.sh"
check "profile.d disables core dumps" bash -c "grep -q 'ulimit -c 0' /etc/profile.d/99-harden-sandbox.sh"
check "onboarding flag exists"        bash -c "test -f /home/vscode/.claude.json || test -f /root/.claude.json"
check "git safe.directory set"        bash -c "git config --system --get-all safe.directory | grep -q '\\*'"

reportResults
