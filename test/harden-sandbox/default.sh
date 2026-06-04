#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "GIT_ASKPASS blanks askpass"   bash -c "[ \"\$GIT_ASKPASS\" = /bin/false ]"
check "GH_TOKEN cleared"              bash -c "[ -z \"\$GH_TOKEN\" ]"
check "GITHUB_TOKEN cleared"          bash -c "[ -z \"\$GITHUB_TOKEN\" ]"
check "AWS_SECRET cleared"            bash -c "[ -z \"\$AWS_SECRET_ACCESS_KEY\" ]"
check "KUBECONFIG cleared"            bash -c "[ -z \"\$KUBECONFIG\" ]"
check "DOCKER_HOST cleared"           bash -c "[ -z \"\$DOCKER_HOST\" ]"
check "GIT_TERMINAL_PROMPT=0"         bash -c "[ \"\$GIT_TERMINAL_PROMPT\" = 0 ]"
check "profile.d script written"      bash -c "test -f /etc/profile.d/99-harden-sandbox.sh"
check "profile.d disables core dumps" bash -c "grep -q 'ulimit -c 0' /etc/profile.d/99-harden-sandbox.sh"
check "profile.d unsets VSCODE IPC"   bash -c "grep -q 'VSCODE_IPC_HOOK_CLI' /etc/profile.d/99-harden-sandbox.sh"
check "onboarding flag exists"        bash -c "test -f /home/vscode/.claude.json"
check "git safe.directory set"        bash -c "git config --system --get-all safe.directory | grep -q '\\*'"
check "commandhistory pre-created"     bash -c "test -d /commandhistory"
check "commandhistory writable by user" bash -c "touch /commandhistory/.probe && rm /commandhistory/.probe"

reportResults
