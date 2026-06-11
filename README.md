# devcontainer-features

Additions to the official [Dev Container Features](https://containers.dev/features), focused on AI coding agents (Codex / CodeGraph) and a hardened, opinionated dev-container experience.

## Features

### AI coding agents

| Feature | What it does |
|---------|--------------|
| [`codex`](./src/codex) | Installs the OpenAI Codex CLI (`@openai/codex`) globally via npm, mirroring the official [anthropics/devcontainer-features](https://github.com/anthropics/devcontainer-features) claude-code feature. Auto-installs Node.js 22 (apt/apk/dnf/yum) when missing, and adds the `openai.chatgpt` VS Code extension. |
| [`codegraph`](./src/codegraph) | Installs [CodeGraph](https://github.com/colbymchenry/codegraph) (`@colbymchenry/codegraph`) — pre-indexed code knowledge graph for Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, Hermes. Optional `cgi` / `cgii` shell aliases. |

### Sandbox & editor

| Feature | What it does |
|---------|--------------|
| [`harden-sandbox`](./src/harden-sandbox) | Blanks credential env vars (GH/GITHUB/AWS/GCP/k8s/Docker tokens, SSH agent, askpass), forces `credential.helper=/bin/false`, sets `no-new-privileges` + `init`, unsets host IPC sockets in interactive shells, disables core dumps, persists shell history (pre-creates `/commandhistory` mode 1777), writes Claude Code onboarding flag, and adds `safe.directory='*'`. |
| [`dev-extensions`](./src/dev-extensions) | Universal VS Code extensions: GitLens (line-level git blame), Simplified Chinese language pack, Markdown Mermaid preview. |
| [`frontend-extensions`](./src/frontend-extensions) | Vue 3 (Volar) + styled-components + Tailwind CSS extensions. Depends on `dev-extensions`. |

## Quick start

Reference any feature in your `devcontainer.json` via its `ghcr.io` ref:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
    }
}
```

After the container builds, run `codex login` once to authenticate (or set `OPENAI_API_KEY` via `remoteEnv` / `containerEnv`).

## Recommended: hardened AI sandbox

If you want an isolated container for letting AI agents run with relaxed approvals, combine `harden-sandbox` with the `runArgs` / mounts that Features cannot set themselves:

```jsonc
{
    "name": "Hardened AI Sandbox",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",

    "runArgs": ["--cap-drop=ALL"],
    "containerUser": "vscode",
    "remoteUser": "vscode",
    "updateRemoteUserUID": true,
    "workspaceFolder": "/workspace",
    "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=delegated",

    "mounts": [
        { "source": "codex-config-${devcontainerId}",  "target": "/home/vscode/.codex", "type": "volume" },
        { "source": "shell-history-${devcontainerId}", "target": "/commandhistory",     "type": "volume" }
    ],

    "remoteEnv": {
        "VSCODE_IPC_HOOK_CLI": null,
        "VSCODE_GIT_IPC_HANDLE": null,
        "REMOTE_CONTAINERS_IPC": null,
        "REMOTE_CONTAINERS_SOCKETS": null,
        "REMOTE_CONTAINERS_DISPLAY_SOCK": null
    },

    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/harden-sandbox:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/codex:1":          {},
        "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1":      { "installAliases": true },
        "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
    }
}
```

This gives you:
- `cap-drop=ALL` + `no-new-privileges` + `init` + named volume persistence
- All host credentials neutralized inside the container
- VS Code's askpass and GitHub-auth integrations disabled
- `cgi` / `cgii` to wire CodeGraph into agents and bootstrap a project index
- Build-time pre-creation of `/commandhistory` so the named-volume mount comes up with the right permissions on first start — no post-mount `chown` needed (which `no-new-privileges` would block anyway)

## How publishing works

Pushed to `ghcr.io/orangeking-leo/devcontainer-features/<feature>:1` via the [`release`](.github/workflows/release.yaml) workflow on every push to `main`. CI tests live in [`test.yaml`](.github/workflows/test.yaml) and run `devcontainer features test` across all features on the `mcr.microsoft.com/devcontainers/base:ubuntu-24.04` base image.

## Local development

```bash
# Run a feature's tests locally without pushing
npm i -g @devcontainers/cli
devcontainer features test \
    --features codex \
    --base-image mcr.microsoft.com/devcontainers/base:ubuntu-24.04 \
    .
```

You can also reference a local feature path directly from a project's `devcontainer.json`:

```jsonc
"features": {
    "./src/codex": {}
}
```

See each feature's `README.md` and `NOTES.md` for full options and the limits of what a Feature can configure (vs. what must live in your `devcontainer.json`).
