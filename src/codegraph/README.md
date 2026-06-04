# CodeGraph (`codegraph`)

Installs [CodeGraph](https://github.com/colbymchenry/codegraph) — a pre-indexed code knowledge graph CLI (`@colbymchenry/codegraph`) that plugs into Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, and Hermes Agent for fewer tokens and fewer tool calls.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {
        "version": "latest",
        "installAliases": true
    }
}
```

After the container starts, wire CodeGraph into your agent(s) once:

```bash
codegraph install        # alias: cgi  (when installAliases is true)
```

Then bootstrap each project:

```bash
cd your-project
codegraph init -i        # alias: cgii (when installAliases is true)
```

## Options

| Options Id    | Description                                                                       | Type    | Default  |
|---------------|-----------------------------------------------------------------------------------|---------|----------|
| `version`     | npm dist-tag or semver of `@colbymchenry/codegraph` to install.                   | string  | `latest` |
| `installNode` | Install Node.js (via NodeSource) when `node` is missing on PATH.                  | boolean | `true`   |
| `nodeVersion` | Major Node.js version used when `installNode` is true.                            | string  | `20`     |
| `installAliases` | Install shell aliases (bash + zsh): `cgi` → `codegraph install`, `cgii` → `codegraph init -i`. | boolean | `false`  |
