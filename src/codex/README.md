# OpenAI Codex (`codex`)

Installs OpenAI's [Codex CLI](https://github.com/openai/codex) (`@openai/codex`) inside a dev container, with optional Node.js bootstrap and starter `config.toml`.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {
        "version": "latest",
        "nodeVersion": "20",
        "installConfig": true
    }
}
```

## Options

| Options Id      | Description                                                                       | Type    | Default  |
|-----------------|-----------------------------------------------------------------------------------|---------|----------|
| `version`       | npm dist-tag or semver of `@openai/codex` to install.                             | string  | `latest` |
| `installNode`   | Install Node.js (via NodeSource) when `node` is missing on PATH.                  | boolean | `true`   |
| `nodeVersion`   | Major Node.js version used when `installNode` is true.                            | string  | `20`     |
| `installConfig` | Write a starter `~/.codex/config.toml` for the remote user if none exists.        | boolean | `false`  |
| `installCxdAlias` | Install shell alias `cxd` → `codex --dangerously-bypass-approvals-and-sandbox` (bash + zsh). **Bypasses approval prompts and sandbox — only enable inside a hardened sandbox.** | boolean | `false`  |
