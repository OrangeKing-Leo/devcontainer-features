# devcontainer-features

Additions to the official [Dev Container Features](https://containers.dev/features), focused on AI coding agents (Claude Code / Codex / CodeGraph) and a hardened, opinionated dev-container experience.

## Features

### AI coding agents

| Feature | What it does |
|---------|--------------|
| [`claude-code`](./src/claude-code) | Installs Anthropic's Claude Code CLI (`@anthropic-ai/claude-code`) via npm. Optional Node bootstrap, starter `settings.json`, and `ccd` shell alias. |
| [`codex`](./src/codex) | Installs OpenAI's Codex CLI (`@openai/codex`) via npm. Optional Node bootstrap, starter `config.toml`, and `cxd` shell alias. |
| [`codegraph`](./src/codegraph) | Installs [CodeGraph](https://github.com/colbymchenry/codegraph) (`@colbymchenry/codegraph`) — pre-indexed code knowledge graph for Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, Hermes. Auto-wires the MCP server into any of those agents, plus `cgi` alias. |

### Sandbox & editor

| Feature | What it does |
|---------|--------------|
| [`harden-sandbox`](./src/harden-sandbox) | Blanks credential env vars (GH/GITHUB/AWS/GCP/k8s/Docker tokens, SSH agent, askpass), forces `credential.helper=/bin/false`, sets `no-new-privileges` + `init`, unsets host IPC sockets in interactive shells, disables core dumps, persists shell history, writes Claude Code onboarding flag, and adds `safe.directory='*'`. |
| [`dev-extensions`](./src/dev-extensions) | Universal VS Code extensions: GitLens (line-level git blame), Simplified Chinese language pack, Markdown Mermaid preview. |
| [`frontend-extensions`](./src/frontend-extensions) | Vue 3 (Volar) + styled-components + Tailwind CSS extensions. Depends on `dev-extensions`. |

## Quick start

Reference any feature in your `devcontainer.json` via its `ghcr.io` ref:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {
            "wireAgents": "all"
        },
        "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
    }
}
```

After the container builds, run `claude login` / `codex login` once to authenticate.

## Recommended: hardened AI sandbox

If you want an isolated container for letting Claude Code / Codex run with permission bypass, combine `harden-sandbox` with the dangerous-alias options and the `runArgs` / mounts that Features cannot set themselves:

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
        { "source": "claude-config-${devcontainerId}",  "target": "/home/vscode/.claude",             "type": "volume" },
        { "source": "claude-data-${devcontainerId}",    "target": "/home/vscode/.local/share/claude", "type": "volume" },
        { "source": "shell-history-${devcontainerId}",  "target": "/commandhistory",                  "type": "volume" }
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
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1":   { "installCcdAlias": true },
        "ghcr.io/orangeking-leo/devcontainer-features/codex:1":         { "installCxdAlias": true },
        "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1":     { "installCgiAlias": true, "wireAgents": "all" },
        "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
    }
}
```

This gives you:
- `cap-drop=ALL` + `no-new-privileges` + `init` + named volume persistence
- All host credentials neutralized inside the container
- VS Code's askpass and GitHub-auth integrations disabled
- `ccd` / `cxd` for one-shot agent runs without permission prompts (safe because the sandbox is locked down)
- `cgi` to bootstrap a CodeGraph index in any project

## How publishing works

Pushed to `ghcr.io/orangeking-leo/devcontainer-features/<feature>:1` via the [`release`](.github/workflows/release.yaml) workflow on every push to `main`. CI tests live in [`test.yaml`](.github/workflows/test.yaml) and run `devcontainer features test` across all features on the `mcr.microsoft.com/devcontainers/base:ubuntu-24.04` base image.

## Local development

```bash
# Run a feature's tests locally without pushing
npm i -g @devcontainers/cli
devcontainer features test \
    --features claude-code \
    --base-image mcr.microsoft.com/devcontainers/base:ubuntu-24.04 \
    .
```

You can also reference a local feature path directly from a project's `devcontainer.json`:

```jsonc
"features": {
    "./src/claude-code": { "installSettings": true }
}
```

See each feature's `README.md` and `NOTES.md` for full options and the limits of what a Feature can configure (vs. what must live in your `devcontainer.json`).
