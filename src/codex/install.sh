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

USER_NAME="${_REMOTE_USER:-vscode}"
if ! id -u "$USER_NAME" >/dev/null 2>&1; then
    USER_NAME="root"
fi
if [ "$USER_NAME" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
fi
USER_GROUP="$(id -gn "$USER_NAME")"

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

setup_user_npm_prefix() {
    # Configure a user-local npm prefix so global installs land under the
    # remote user's HOME — this lets Codex's auto-updater (and any peer
    # claude-code feature) write to its own install dir without root.
    if [ "$USER_NAME" = "root" ]; then
        echo "Remote user is root — skipping user-local npm prefix."
        return 0
    fi

    local prefix_dir="${USER_HOME}/.npm-global"
    install -d -o "$USER_NAME" -g "$USER_GROUP" -m 0755 "$prefix_dir"

    local npmrc="${USER_HOME}/.npmrc"
    if [ ! -f "$npmrc" ] || ! grep -q '^prefix=' "$npmrc"; then
        echo 'prefix=${HOME}/.npm-global' >> "$npmrc"
        chown "$USER_NAME:$USER_GROUP" "$npmrc"
        chmod 0644 "$npmrc"
    fi

    install -d -m 0755 /etc/profile.d
    local path_file="/etc/profile.d/codex-path.sh"
    cat > "$path_file" <<'SH'
# Injected by the codex dev container feature: put the per-user
# npm-global bin first so `codex` (and other user-installed CLIs) win
# over system copies. Safe to coexist with claude-code-path.sh.
if [ -d "$HOME/.npm-global/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.npm-global/bin:"*) ;;
        *) export PATH="$HOME/.npm-global/bin:$PATH" ;;
    esac
fi
SH
    chmod 0644 "$path_file"
    if [ -f /etc/bash.bashrc ] && ! grep -q "codex-path.sh" /etc/bash.bashrc; then
        echo '[ -r /etc/profile.d/codex-path.sh ] && . /etc/profile.d/codex-path.sh' >> /etc/bash.bashrc
    fi
    if command -v zsh >/dev/null 2>&1; then
        install -d -m 0755 /etc/zsh
        if ! grep -q "codex-path.sh" /etc/zsh/zshenv 2>/dev/null; then
            echo '[ -r /etc/profile.d/codex-path.sh ] && . /etc/profile.d/codex-path.sh' >> /etc/zsh/zshenv
        fi
    fi
    echo "Configured user-local npm prefix at ${prefix_dir}"
}

install_codex() {
    local spec="@openai/codex"
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        spec="${spec}@${VERSION}"
    else
        spec="${spec}@latest"
    fi
    echo "Installing ${spec} globally via npm (as ${USER_NAME})..."
    if [ "$USER_NAME" = "root" ]; then
        npm install -g --no-audit --no-fund "$spec"
    else
        su - "$USER_NAME" -c "npm install -g --no-audit --no-fund $(printf %q "$spec")"
    fi
    echo "Installed codex under ${USER_HOME}/.npm-global (or system prefix for root)."
}

prepare_codex_home() {
    # Pre-create ~/.codex owned by the remote user so a named-volume mount
    # inherits correct ownership on first container start. Must happen at
    # build time because the harden-sandbox feature's no-new-privileges
    # securityOpt prevents any post-mount chown via sudo.
    mkdir -p "${USER_HOME}/.codex"
    chown "${USER_NAME}:${USER_GROUP}" "${USER_HOME}/.codex"
    chmod 0755 "${USER_HOME}/.codex"
    echo "Pre-created ${USER_HOME}/.codex owned by ${USER_NAME}"
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
    setup_user_npm_prefix
    install_codex
    prepare_codex_home
    install_cxd_alias
    echo "codex feature install complete."
}

main "$@"
