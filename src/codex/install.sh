#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLNODE="${INSTALLNODE:-true}"
NODEVERSION="${NODEVERSION:-20}"
INSTALLCXDALIAS="${INSTALLCXDALIAS:-false}"

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

install_codex() {
    local spec="@openai/codex"
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        spec="${spec}@${VERSION}"
    else
        spec="${spec}@latest"
    fi
    echo "Installing ${spec} globally via npm..."
    npm install -g --no-audit --no-fund "$spec"
    echo "Installed: $(codex --version 2>/dev/null || echo 'codex command not on PATH yet')"
}

prepare_codex_home() {
    # Pre-create ~/.codex owned by the remote user so a named-volume mount
    # inherits correct ownership on first container start. Must happen at
    # build time because the harden-sandbox feature's no-new-privileges
    # securityOpt prevents any post-mount chown via sudo.
    local user="${_REMOTE_USER:-vscode}"
    local home="${_REMOTE_USER_HOME:-/home/${user}}"
    if ! id -u "$user" >/dev/null 2>&1; then
        echo "Remote user '${user}' not present — skipping ~/.codex pre-create."
        return 0
    fi
    install -d -o "$user" -g "$(id -gn "$user")" -m 0755 "${home}/.codex"
    echo "Pre-created ${home}/.codex owned by ${user}"
}

install_cxd_alias() {
    [ "${INSTALLCXDALIAS,,}" = "true" ] || return 0
    local alias_file="/etc/profile.d/codex-aliases.sh"
    install -d -m 0755 /etc/profile.d
    cat > "$alias_file" <<'SH'
# Injected by the codex dev container feature (installCxdAlias=true).
# WARNING: --dangerously-bypass-approvals-and-sandbox skips both Codex's
# approval prompts and sandbox restrictions. Only meaningful inside an
# isolated container.
alias cxd='codex --dangerously-bypass-approvals-and-sandbox'
SH
    chmod 0644 "$alias_file"
    if [ -f /etc/bash.bashrc ] && ! grep -q "codex-aliases.sh" /etc/bash.bashrc; then
        echo '[ -r /etc/profile.d/codex-aliases.sh ] && . /etc/profile.d/codex-aliases.sh' >> /etc/bash.bashrc
    fi
    if command -v zsh >/dev/null 2>&1; then
        install -d -m 0755 /etc/zsh
        if ! grep -q "codex-aliases.sh" /etc/zsh/zshrc 2>/dev/null; then
            echo '[ -r /etc/profile.d/codex-aliases.sh ] && . /etc/profile.d/codex-aliases.sh' >> /etc/zsh/zshrc
        fi
    fi
    echo "Installed 'cxd' alias to ${alias_file}"
}

main() {
    install_node_if_missing
    install_codex
    prepare_codex_home
    install_cxd_alias
    echo "codex feature install complete."
}

main "$@"
