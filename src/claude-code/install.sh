#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLNODE="${INSTALLNODE:-true}"
NODEVERSION="${NODEVERSION:-20}"
INSTALLCCDALIAS="${INSTALLCCDALIAS:-false}"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: install.sh must run as root." >&2
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        apt-get -o Acquire::Retries=5 update -y
    fi
}

ensure_pkgs() {
    apt_get_update
    apt-get -o Acquire::Retries=5 install -y --no-install-recommends "$@"
}

install_node_if_missing() {
    if command -v node >/dev/null 2>&1; then
        echo "Node.js already installed: $(node -v)"
        return
    fi
    if [ "${INSTALLNODE,,}" != "true" ]; then
        echo "ERROR: node not found and installNode=false." >&2
        exit 1
    fi
    echo "Installing Node.js ${NODEVERSION}.x via NodeSource..."
    ensure_pkgs curl ca-certificates gnupg
    curl -fsSL "https://deb.nodesource.com/setup_${NODEVERSION}.x" | bash -
    apt-get install -y --no-install-recommends nodejs
}

install_claude_code() {
    local spec="@anthropic-ai/claude-code"
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        spec="${spec}@${VERSION}"
    else
        spec="${spec}@latest"
    fi
    echo "Installing ${spec} globally via npm..."
    npm install -g --no-audit --no-fund "$spec"
    echo "Installed: $(claude --version 2>/dev/null || echo 'claude command not on PATH yet')"
}

install_ccd_alias() {
    [ "${INSTALLCCDALIAS,,}" = "true" ] || return 0
    local alias_file="/etc/profile.d/claude-code-aliases.sh"
    install -d -m 0755 /etc/profile.d
    cat > "$alias_file" <<'SH'
# Injected by the claude-code dev container feature (installCcdAlias=true).
# WARNING: --dangerously-skip-permissions bypasses Claude Code's per-tool
# permission prompts. Only meaningful inside an isolated sandbox.
alias ccd='claude --dangerously-skip-permissions'
SH
    chmod 0644 "$alias_file"
    # Bridge to non-login bash via /etc/bash.bashrc (login shells already
    # source /etc/profile.d). Bridge to zsh via /etc/zsh/zshrc.
    if [ -f /etc/bash.bashrc ] && ! grep -q "claude-code-aliases.sh" /etc/bash.bashrc; then
        echo '[ -r /etc/profile.d/claude-code-aliases.sh ] && . /etc/profile.d/claude-code-aliases.sh' >> /etc/bash.bashrc
    fi
    if command -v zsh >/dev/null 2>&1; then
        install -d -m 0755 /etc/zsh
        if ! grep -q "claude-code-aliases.sh" /etc/zsh/zshrc 2>/dev/null; then
            echo '[ -r /etc/profile.d/claude-code-aliases.sh ] && . /etc/profile.d/claude-code-aliases.sh' >> /etc/zsh/zshrc
        fi
    fi
    echo "Installed 'ccd' alias to ${alias_file}"
}

main() {
    install_node_if_missing
    install_claude_code
    install_ccd_alias
    echo "claude-code feature install complete."
}

main "$@"
