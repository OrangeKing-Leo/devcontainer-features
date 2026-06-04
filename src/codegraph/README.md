# CodeGraph (`codegraph`)

Installs [CodeGraph](https://github.com/colbymchenry/codegraph) — a pre-indexed code knowledge graph CLI (`@colbymchenry/codegraph`) that plugs into Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, and Hermes Agent for fewer tokens and fewer tool calls.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {
        "version": "latest",
        "wireAgents": "claude-code"
    }
}
```

## Options

| Options Id    | Description                                                                                                                                                | Type    | Default  |
|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|----------|
| `version`     | npm dist-tag or semver of `@colbymchenry/codegraph` to install.                                                                                            | string  | `latest` |
| `installNode` | Install Node.js (via NodeSource) when `node` is missing on PATH.                                                                                           | boolean | `true`   |
| `nodeVersion` | Major Node.js version used when `installNode` is true.                                                                                                     | string  | `20`     |
| `wireAgents`  | Run `codegraph install --target <value> --yes` at build to wire MCP server into an agent. One of `none`, `all`, `claude-code`, `codex`, `cursor`, `opencode`, `hermes`, `gemini`, `antigravity`, `kiro`. | string  | `none`   |
| `installCgiAlias` | Install shell alias `cgi` → `codegraph init -i` (bash + zsh) for fast project setup.                                                                  | boolean | `false`  |
