#!/usr/bin/env bash
set -euo pipefail

UNSETHOSTIPC="${UNSETHOSTIPC:-true}"
WRITEONBOARDINGFLAG="${WRITEONBOARDINGFLAG:-true}"
ADDGITSAFEDIRECTORY="${ADDGITSAFEDIRECTORY:-true}"
DISABLECOREDUMPS="${DISABLECOREDUMPS:-true}"
PERSISTSHELLHISTORY="${PERSISTSHELLHISTORY:-true}"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: install.sh must run as root." >&2
    exit 1
fi

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

USER_NAME="$(detect_user)"
if [ "$USER_NAME" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
fi
USER_GROUP="$(id -gn "$USER_NAME")"

# ---------- 1. /etc/profile.d hardening script ----------
PROFILE_SCRIPT="/etc/profile.d/99-harden-sandbox.sh"
install -d -m 0755 /etc/profile.d
{
    echo "# Injected by the harden-sandbox dev container feature."
    echo "# Hardens interactive shells with defence-in-depth measures."
    if [ "${UNSETHOSTIPC,,}" = "true" ]; then
        cat <<'SH'

# Unset host IPC / display / agent variables that may leak from the host
# into the container shell (mirrors remoteEnv: null in devcontainer.json).
unset VSCODE_IPC_HOOK_CLI
unset VSCODE_GIT_IPC_HANDLE
unset REMOTE_CONTAINERS_IPC
unset REMOTE_CONTAINERS_SOCKETS
unset REMOTE_CONTAINERS_DISPLAY_SOCK
unset GPG_AGENT_INFO
unset BROWSER
unset WAYLAND_DISPLAY
unset DISPLAY
SH
    fi
    if [ "${DISABLECOREDUMPS,,}" = "true" ]; then
        cat <<'SH'

# Disable core dumps — in-memory secrets must not hit disk.
ulimit -c 0 2>/dev/null || true
SH
    fi
    if [ "${PERSISTSHELLHISTORY,,}" = "true" ]; then
        cat <<'SH'

# Redirect shell history to a persistent location when /commandhistory is mounted.
if [ -d /commandhistory ]; then
    if [ -n "${BASH_VERSION:-}" ]; then
        export HISTFILE=/commandhistory/.bash_history
    elif [ -n "${ZSH_VERSION:-}" ]; then
        export HISTFILE=/commandhistory/.zsh_history
    fi
    export HISTSIZE=10000
    export SAVEHIST=10000
    export HISTTIMEFORMAT='%F %T  '
fi
SH
    fi
} > "$PROFILE_SCRIPT"
chmod 0644 "$PROFILE_SCRIPT"

# zsh does not source /etc/profile.d unless invoked as a login shell; bridge it.
if command -v zsh >/dev/null 2>&1; then
    install -d -m 0755 /etc/zsh
    if ! grep -q "99-harden-sandbox.sh" /etc/zsh/zshenv 2>/dev/null; then
        echo '[ -r /etc/profile.d/99-harden-sandbox.sh ] && . /etc/profile.d/99-harden-sandbox.sh' >> /etc/zsh/zshenv
    fi
fi
echo "Wrote ${PROFILE_SCRIPT}"

# ---------- 2. Write Claude Code onboarding flag ----------
if [ "${WRITEONBOARDINGFLAG,,}" = "true" ]; then
    FLAG_PATH="${USER_HOME}/.claude.json"
    if [ -f "$FLAG_PATH" ]; then
        echo "Onboarding flag already exists at ${FLAG_PATH} — leaving untouched."
    else
        cat > "$FLAG_PATH" <<'JSON'
{"hasCompletedOnboarding":true,"numStartups":1,"installMethod":"native"}
JSON
        if [ "$USER_NAME" != "root" ]; then
            chown "$USER_NAME:$USER_GROUP" "$FLAG_PATH"
        fi
        chmod 0644 "$FLAG_PATH"
        echo "Wrote onboarding flag to ${FLAG_PATH}"
    fi
fi

# ---------- 3. git safe.directory ----------
if [ "${ADDGITSAFEDIRECTORY,,}" = "true" ]; then
    if command -v git >/dev/null 2>&1; then
        # System-wide safe.directory so any bind-mounted repo (regardless of
        # uid mismatch with the remote user) is trusted.
        git config --system --add safe.directory '*'
        echo "Added system-wide git safe.directory='*'"
    else
        echo "git not present — skipping safe.directory setup."
    fi
fi

# ---------- 4. Pre-create /commandhistory owned by remote user ----------
# A named-volume mount inherits ownership from the dir that exists inside
# the image at first start. We create it here while still root so that
# (a) the user can write to it without sudo, and (b) this works even
# under no-new-privileges where post-mount chown is impossible.
if [ "${PERSISTSHELLHISTORY,,}" = "true" ] && [ "$USER_NAME" != "root" ]; then
    install -d -o "$USER_NAME" -g "$USER_GROUP" -m 0755 /commandhistory
    echo "Pre-created /commandhistory owned by ${USER_NAME}"
fi

echo "harden-sandbox feature install complete."
