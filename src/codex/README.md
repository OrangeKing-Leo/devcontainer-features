# OpenAI Codex (`codex`)

Installs OpenAI's [Codex CLI](https://github.com/openai/codex) (`@openai/codex`) inside a dev container, with optional Node.js bootstrap.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {
        "version": "latest",
        "nodeVersion": "20"
    }
}
```

## Options

| Options Id      | Description                                                                       | Type    | Default  |
|-----------------|-----------------------------------------------------------------------------------|---------|----------|
| `version`       | npm dist-tag or semver of `@openai/codex` to install.                             | string  | `latest` |
| `installNode`   | Install Node.js (via NodeSource) when `node` is missing on PATH.                  | boolean | `true`   |
| `nodeVersion`   | Major Node.js version used when `installNode` is true.                            | string  | `20`     |
| `installCxdAlias` | Install shell alias `cxd` → `codex --dangerously-bypass-approvals-and-sandbox` (bash + zsh). **Bypasses approval prompts and sandbox — only enable inside a hardened sandbox.** | boolean | `false`  |
