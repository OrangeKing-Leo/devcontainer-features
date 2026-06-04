#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALLNODE="${INSTALLNODE:-true}"
NODEVERSION="${NODEVERSION:-20}"
WIREAGENTS="${WIREAGENTS:-none}"

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

install_codegraph() {
    local spec="@colbymchenry/codegraph"
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        spec="${spec}@${VERSION}"
    else
        spec="${spec}@latest"
    fi
    echo "Installing ${spec} globally via npm..."
    npm install -g --no-audit --no-fund "$spec"
    echo "Installed: $(codegraph --version 2>/dev/null || echo 'codegraph command not on PATH yet')"
}

wire_agents() {
    local target="${WIREAGENTS,,}"
    [ "$target" = "none" ] || [ -z "$target" ] && { echo "Skipping agent wiring (wireAgents=none)."; return 0; }

    local user home
    user="$(detect_user)"
    if [ "$user" = "root" ]; then
        home="/root"
    else
        home="$(getent passwd "$user" | cut -d: -f6)"
    fi

    local cmd="codegraph install --yes"
    [ "$target" != "all" ] && cmd="${cmd} --target ${target}"

    echo "Wiring CodeGraph into agent(s): ${target} (as ${user})..."
    if [ "$user" = "root" ]; then
        eval "$cmd" || echo "WARN: 'codegraph install' did not complete cleanly — agent may not be present in image."
    else
        su - "$user" -c "$cmd" || echo "WARN: 'codegraph install' did not complete cleanly — agent may not be present in image."
    fi
}

main() {
    install_node_if_missing
    install_codegraph
    wire_agents
    echo "codegraph feature install complete."
}

main "$@"
