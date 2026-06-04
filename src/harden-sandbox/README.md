# Harden Dev Container Sandbox (`harden-sandbox`)

Sandbox-hardening for dev containers running AI coding agents (Claude Code / Codex / …). Blocks credential leakage from the host, unsets VS Code / remote-containers IPC sockets, sets `no-new-privileges`, enables `init`, and pre-skips Claude Code's onboarding prompt.

## Example Usage

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "runArgs": ["--cap-drop=ALL"],
    "remoteUser": "vscode",
    "containerUser": "vscode",
    "updateRemoteUserUID": true,
    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/harden-sandbox:1": {}
    }
}
```

## Options

| Options Id             | Description                                                                                                          | Type    | Default |
|------------------------|----------------------------------------------------------------------------------------------------------------------|---------|---------|
| `unsetHostIpc`         | Write `/etc/profile.d/99-harden-sandbox.sh` to unset VS Code / remote-containers / GPG / display IPC env vars.       | boolean | `true`  |
| `writeOnboardingFlag`  | Write `~/.claude.json` so Claude Code skips the first-run onboarding prompt.                                         | boolean | `true`  |
| `addGitSafeDirectory`  | Add system-wide `git config --system --add safe.directory '*'` to avoid "dubious ownership" on bind-mounted repos.   | boolean | `true`  |
| `disableCoreDumps`     | Set `ulimit -c 0` in `/etc/profile.d` so core dumps with secrets cannot land on disk.                                | boolean | `true`  |
| `persistShellHistory`  | Redirect bash/zsh `HISTFILE` to `/commandhistory/.{bash,zsh}_history` when `/commandhistory` is mounted.             | boolean | `true`  |
