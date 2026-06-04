#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLNODE="${INSTALLNODE:-true}"
NODEVERSION="${NODEVERSION:-20}"
INSTALLSETTINGS="${INSTALLSETTINGS:-false}"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: install.sh must run as root." >&2
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        apt-get update -y
    fi
}

ensure_pkgs() {
    apt_get_update
    apt-get install -y --no-install-recommends "$@"
}

detect_user() {
    local candidates=("${_REMOTE_USER:-}" "${USERNAME:-}" vscode node codespace ubuntu)
    for u in "${candidates[@]}"; do
        if [ -n "$u" ] && id -u "$u" >/dev/null 2>&1; then
            echo "$u"
            return 0
        fi
    done
    echo "root"
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

write_starter_settings() {
    [ "${INSTALLSETTINGS,,}" = "true" ] || return 0
    local user home settings
    user="$(detect_user)"
    if [ "$user" = "root" ]; then
        home="/root"
    else
        home="$(getent passwd "$user" | cut -d: -f6)"
    fi
    settings="${home}/.claude/settings.json"
    if [ -f "$settings" ]; then
        echo "Existing ${settings} found — leaving untouched."
        return 0
    fi
    install -d -m 0755 "${home}/.claude"
    cat > "$settings" <<'JSON'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [],
    "deny": []
  }
}
JSON
    if [ "$user" != "root" ]; then
        chown -R "$user:$(id -gn "$user")" "${home}/.claude"
    fi
    echo "Wrote starter settings to ${settings}"
}

main() {
    install_node_if_missing
    install_claude_code
    write_starter_settings
    echo "claude-code feature install complete."
}

main "$@"
