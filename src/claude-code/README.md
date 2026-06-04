# Claude Code (`claude-code`)

Installs Anthropic's [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) CLI (`@anthropic-ai/claude-code`) inside a dev container, with optional Node.js bootstrap and starter `settings.json`.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {
        "version": "latest",
        "nodeVersion": "20",
        "installSettings": true
    }
}
```

## Options

| Options Id        | Description                                                                            | Type    | Default  |
|-------------------|----------------------------------------------------------------------------------------|---------|----------|
| `version`         | npm dist-tag or semver of `@anthropic-ai/claude-code` to install.                      | string  | `latest` |
| `installNode`     | Install Node.js (via NodeSource) when `node` is missing on PATH.                       | boolean | `true`   |
| `nodeVersion`     | Major Node.js version used when `installNode` is true.                                 | string  | `20`     |
| `installSettings` | Write a starter `~/.claude/settings.json` for the remote user if none exists.          | boolean | `false`  |
| `installCcdAlias` | Install shell alias `ccd` → `claude --dangerously-skip-permissions` (bash + zsh). **Bypasses permission prompts — only enable inside a hardened sandbox.** | boolean | `false`  |
