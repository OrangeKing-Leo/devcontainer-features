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
    # remote user's HOME — this lets Claude Code's auto-updater write to its
    # own install dir without root. When the remote user is root, we skip
    # this and let npm use its system-wide default.
    if [ "$USER_NAME" = "root" ]; then
        echo "Remote user is root — skipping user-local npm prefix."
        return 0
    fi

    local prefix_dir="${USER_HOME}/.npm-global"
    install -d -o "$USER_NAME" -g "$USER_GROUP" -m 0755 "$prefix_dir"

    # Per-user npmrc — npm expands ${HOME} when reading config files.
    local npmrc="${USER_HOME}/.npmrc"
    if [ ! -f "$npmrc" ] || ! grep -q '^prefix=' "$npmrc"; then
        echo 'prefix=${HOME}/.npm-global' >> "$npmrc"
        chown "$USER_NAME:$USER_GROUP" "$npmrc"
        chmod 0644 "$npmrc"
    fi

    # System-wide PATH addition so non-login shells pick up the user's
    # npm-global bin (login shells already source /etc/profile.d).
    install -d -m 0755 /etc/profile.d
    cat > /etc/profile.d/claude-code-path.sh <<'SH'
# Injected by the claude-code dev container feature: put the per-user
# npm-global bin first so `claude` (and any other user-installed CLIs)
# win over system copies.
if [ -d "$HOME/.npm-global/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.npm-global/bin:"*) ;;
        *) export PATH="$HOME/.npm-global/bin:$PATH" ;;
    esac
fi
SH
    chmod 0644 /etc/profile.d/claude-code-path.sh
    if [ -f /etc/bash.bashrc ] && ! grep -q "claude-code-path.sh" /etc/bash.bashrc; then
        echo '[ -r /etc/profile.d/claude-code-path.sh ] && . /etc/profile.d/claude-code-path.sh' >> /etc/bash.bashrc
    fi
    if command -v zsh >/dev/null 2>&1; then
        install -d -m 0755 /etc/zsh
        if ! grep -q "claude-code-path.sh" /etc/zsh/zshenv 2>/dev/null; then
            echo '[ -r /etc/profile.d/claude-code-path.sh ] && . /etc/profile.d/claude-code-path.sh' >> /etc/zsh/zshenv
        fi
    fi
    echo "Configured user-local npm prefix at ${prefix_dir}"
}

install_claude_code() {
    local spec="@anthropic-ai/claude-code"
    if [ "$VERSION" != "latest" ] && [ -n "$VERSION" ]; then
        spec="${spec}@${VERSION}"
    else
        spec="${spec}@latest"
    fi
    echo "Installing ${spec} globally via npm (as ${USER_NAME})..."
    if [ "$USER_NAME" = "root" ]; then
        npm install -g --no-audit --no-fund "$spec"
    else
        # Login shell so /etc/profile.d (PATH) and ~/.npmrc (prefix) are picked up.
        su - "$USER_NAME" -c "npm install -g --no-audit --no-fund $(printf %q "$spec")"
    fi
    echo "Installed claude-code under ${USER_HOME}/.npm-global (or system prefix for root)."
}

prepare_claude_home() {
    # Pre-create ~/.claude owned by the remote user so a named-volume mount
    # (e.g. claude-config-${devcontainerId}) inherits correct ownership on
    # first container start. This must happen at build time because the
    # harden-sandbox feature's no-new-privileges securityOpt prevents any
    # post-mount chown via sudo.
    mkdir -p "${USER_HOME}/.claude"
    chown "${USER_NAME}:${USER_GROUP}" "${USER_HOME}/.claude"
    chmod 0755 "${USER_HOME}/.claude"
    echo "Pre-created ${USER_HOME}/.claude owned by ${USER_NAME}"
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
    setup_user_npm_prefix
    install_claude_code
    prepare_claude_home
    install_ccd_alias
    echo "claude-code feature install complete."
}

main "$@"
