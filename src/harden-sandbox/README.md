
# Harden Dev Container Sandbox (harden-sandbox)

Hardens the dev container sandbox: blocks credential leaks (GH_TOKEN, SSH agent, git askpass), unsets host IPC variables, sets git safe.directory, and writes Claude Code onboarding flag. Pair with runArgs cap-drop and named volume mounts in your devcontainer.json for full isolation.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/harden-sandbox:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| unsetHostIpc | Write /etc/profile.d/99-harden-sandbox.sh to unset VS Code / remote-containers / GPG / display IPC env vars in interactive shells. | boolean | true |
| writeOnboardingFlag | Write ~/.claude.json with hasCompletedOnboarding=true so Claude Code skips the first-run prompt. | boolean | true |
| addGitSafeDirectory | Add /workspace (and the detected workspace path) as a global git safe.directory to avoid 'dubious ownership' errors on bind-mounted repos. | boolean | true |
| disableCoreDumps | Set 'ulimit -c 0' in /etc/profile.d so processes cannot leave core dumps (which may contain in-memory secrets) on disk. | boolean | true |
| persistShellHistory | Redirect bash/zsh HISTFILE to /commandhistory/.shell_history when /commandhistory exists (pairs with a named-volume mount in your devcontainer.json). | boolean | true |

## What this feature contributes

| Layer | Hardening |
|-------|-----------|
| `containerEnv` | Blanks credential / agent env vars that leak from the host: `GH_TOKEN`, `GITHUB_TOKEN`, `NPM_TOKEN`, `SSH_AUTH_SOCK`, `VSCODE_GIT_ASKPASS_*`, AWS (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_PROFILE`), GCP (`GOOGLE_APPLICATION_CREDENTIALS`, `GCLOUD_PROJECT`), Kubernetes (`KUBECONFIG`), Docker (`DOCKER_HOST`, `DOCKER_TLS_VERIFY`, `DOCKER_CERT_PATH`). Forces `GIT_ASKPASS=/bin/false`, `GIT_TERMINAL_PROMPT=0`, and `credential.helper=/bin/false` via `GIT_CONFIG_*` so cached git creds are ignored. |
| `securityOpt` | `no-new-privileges` — processes inside the container cannot gain new capabilities via setuid binaries. |
| `init` | `tini`-style init enabled, so signals propagate and zombies are reaped. |
| `customizations.vscode.settings` | Disables VS Code's GitHub auth integration and the integrated git askpass. |
| `install.sh` | Writes `/etc/profile.d/99-harden-sandbox.sh` (also bridged to zsh via `/etc/zsh/zshenv`) covering: unset of VSCode / remote-containers / GPG / display IPC vars, `ulimit -c 0` to block core dumps, and `HISTFILE` redirect to `/commandhistory/*` when that volume is mounted. Optionally writes `~/.claude.json` onboarding flag and `git --system safe.directory='*'`. |

## What this feature cannot do — add these to your `devcontainer.json` yourself

The dev container Features spec does not allow features to set `runArgs`, `remoteEnv` (top-level), `remoteUser`, `workspaceMount`, etc. For full hardening, your `devcontainer.json` should also include:

```jsonc
{
    "name": "Hardened Claude Code Sandbox",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",

    // Drop all Linux capabilities — combine with this feature's no-new-privileges.
    "runArgs": ["--cap-drop=ALL"],

    // Run as the non-root vscode user end-to-end.
    "containerUser": "vscode",
    "remoteUser": "vscode",
    "updateRemoteUserUID": true,

    // Bind workspace with delegated consistency for macOS perf.
    "workspaceFolder": "/workspace",
    "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=delegated",

    // Persist Claude Code state across rebuilds in per-container named volumes.
    "mounts": [
        { "source": "claude-code-config-${devcontainerId}",      "target": "/home/vscode/.claude",             "type": "volume" },
        { "source": "claude-code-data-${devcontainerId}",        "target": "/home/vscode/.local/share/claude", "type": "volume" },
        { "source": "claude-code-bashhistory-${devcontainerId}", "target": "/commandhistory",                  "type": "volume" }
    ],

    // remoteEnv keys set to null tell VS Code NOT to forward those host env vars
    // into the remote process tree. The feature also defends with /etc/profile.d
    // but this catches the non-shell path (extensions, VS Code Server processes).
    "remoteEnv": {
        "VSCODE_IPC_HOOK_CLI": null,
        "VSCODE_GIT_IPC_HANDLE": null,
        "REMOTE_CONTAINERS_IPC": null,
        "REMOTE_CONTAINERS_SOCKETS": null,
        "REMOTE_CONTAINERS_DISPLAY_SOCK": null,
        "GPG_AGENT_INFO": "",
        "BROWSER": "",
        "WAYLAND_DISPLAY": ""
    },

    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/harden-sandbox:1": {}
    }
}
```

## Why both `containerEnv` + `remoteEnv` + `/etc/profile.d`?

- **`containerEnv`** (set by this feature) — baked into the container so process trees started by docker exec inherit them.
- **`remoteEnv: null`** (you set in `devcontainer.json`) — tells VS Code Server not to forward the host's IPC sockets into the remote process tree. This is the only way to block extensions/VS Code Server from leaking IPC.
- **`/etc/profile.d/99-harden-sandbox.sh`** (this feature) — defense-in-depth for any interactive shell that bypasses the above (terminal sessions opened outside VS Code's launch path).

Each layer covers a different code path. Use all three for a tight sandbox.

## Optional extra `runArgs` for stricter sandboxing

These cannot be set by a feature — add them to your `devcontainer.json` when you want a tighter sandbox:

```jsonc
"runArgs": [
    "--cap-drop=ALL",
    "--security-opt=no-new-privileges",   // redundant with this feature, harmless
    "--pids-limit=512",                   // bound the number of processes
    "--memory=4g",                        // hard memory cap
    "--cpus=2",                           // hard CPU cap
    "--read-only",                        // root filesystem read-only
    "--tmpfs=/tmp:size=512m,exec",        // restore a writable /tmp when using --read-only
    "--tmpfs=/run:size=64m"
]
```

When using `--read-only`, expect breakage in tools that write outside `/tmp`, `/workspace`, or your mounted volumes — add per-path `--tmpfs` mounts as needed.

For network isolation, `--network=none` blocks all egress; usually too strict for AI agents that need to reach the API. A middle-ground is a custom docker network that only allows DNS + the agent's API host.

## Known limitations

- `--cap-drop=ALL` may break tools that need specific capabilities (e.g., `ping` needs `CAP_NET_RAW`). Add them back with `--cap-add` as needed.
- `safe.directory='*'` weakens git's defence against malicious repo ownership. If you only ever mount your own repos, this is fine; for shared images, scope to specific paths instead.
- Setting `SSH_AUTH_SOCK=""` blocks SSH agent forwarding. If you need to push over SSH from inside the container, omit this feature or override `containerEnv` in your `devcontainer.json`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
