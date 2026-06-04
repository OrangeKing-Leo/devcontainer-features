#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLNODE="${INSTALLNODE:-true}"
NODEVERSION="${NODEVERSION:-20}"
INSTALLCONFIG="${INSTALLCONFIG:-false}"

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

write_starter_config() {
    [ "${INSTALLCONFIG,,}" = "true" ] || return 0
    local user home config
    user="$(detect_user)"
    if [ "$user" = "root" ]; then
        home="/root"
    else
        home="$(getent passwd "$user" | cut -d: -f6)"
    fi
    config="${home}/.codex/config.toml"
    if [ -f "$config" ]; then
        echo "Existing ${config} found — leaving untouched."
        return 0
    fi
    install -d -m 0755 "${home}/.codex"
    cat > "$config" <<'TOML'
# Starter Codex CLI configuration.
# See https://github.com/openai/codex for the full schema.

# model = "gpt-5-codex"
# approval_policy = "on-request"
# sandbox_mode = "workspace-write"
TOML
    if [ "$user" != "root" ]; then
        chown -R "$user:$(id -gn "$user")" "${home}/.codex"
    fi
    echo "Wrote starter config to ${config}"
}

main() {
    install_node_if_missing
    install_codex
    write_starter_config
    echo "codex feature install complete."
}

main "$@"
