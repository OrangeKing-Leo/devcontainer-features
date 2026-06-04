# devcontainer-features

Additions to the official [Dev Container Features](https://containers.dev/features).

## Features

| Feature                                | Description                                                                 |
|----------------------------------------|-----------------------------------------------------------------------------|
| [`claude-code`](./src/claude-code)     | Installs Anthropic's Claude Code CLI (`@anthropic-ai/claude-code`) via npm. |
| [`codegraph`](./src/codegraph)         | Installs CodeGraph (`@colbymchenry/codegraph`) — pre-indexed code knowledge graph for AI coding agents. |
| [`codex`](./src/codex)                 | Installs OpenAI's Codex CLI (`@openai/codex`) via npm. |
| [`harden-sandbox`](./src/harden-sandbox) | Hardens the dev container: blanks credential env vars, drops capabilities, unsets host IPC sockets, disables core dumps, persists shell history, writes Claude Code onboarding flag. |

## Usage

```jsonc
{
    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {}
    }
}
```

See each feature's `README.md` for available options.
