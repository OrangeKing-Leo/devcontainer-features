
# CodeGraph CLI (codegraph)

Installs the CodeGraph CLI (@colbymchenry/codegraph) — a pre-indexed code knowledge graph for Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, and Hermes Agent.

## Example Usage

```json
"features": {
    "ghcr.io/OrangeKing-Leo/devcontainer-features/codegraph:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @colbymchenry/codegraph to install (npm dist-tag or semver, e.g. 'latest', '1.0.0'). | string | latest |
| installNode | Install Node.js (via NodeSource) if 'node' is not already on PATH. Disable if you supply Node yourself. | boolean | true |
| nodeVersion | Major Node.js version to install when installNode is true (e.g. '18', '20', '22'). | string | 20 |
| wireAgents | Run `codegraph install --target <value> --yes` at build time to wire CodeGraph's MCP server into the chosen agent(s). 'none' skips wiring; 'all' wires every detected agent. Note: agents must already be installed in the image for wiring to succeed. | string | none |

## OS Support

This feature targets Debian/Ubuntu based images (uses `apt-get`). Tested on:

- `mcr.microsoft.com/devcontainers/base:ubuntu`
- `mcr.microsoft.com/devcontainers/base:debian`

Not supported on Alpine.

## Requirements

- Node.js 18 or newer. If `node` is not on `PATH`, the feature installs Node via NodeSource (controlled by `installNode` / `nodeVersion`).
- Outbound access to `registry.npmjs.org` (and `deb.nodesource.com` when Node is auto-installed).

## Wiring agents

The `wireAgents` option runs `codegraph install --target <value> --yes` during build. For this to succeed **the target agent must already be installed in the image**:

- For Claude Code, pair this feature with [`claude-code`](../claude-code) (it is declared in `installsAfter` so ordering is correct):

    ```jsonc
    "features": {
        "ghcr.io/orangeking-leo/devcontainer-features/claude-code:1": {},
        "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {
            "wireAgents": "claude-code"
        }
    }
    ```

- If the agent is not present at build time, wiring is skipped with a warning. You can wire it later from inside the container with `codegraph install`.

`wireAgents: "all"` runs the auto-detect flow against every agent CodeGraph knows about — only ones actually installed will be configured.

## Per-project index

This feature installs the CLI only. Initialize each project after `cd`-ing into it:

```bash
codegraph init -i
```

`-i` (`--index`) builds the initial graph. Without `-i`, run `codegraph index` afterwards.

## Uninstall

To strip CodeGraph from configured agents:

```bash
codegraph uninstall
```

Project indexes under `.codegraph/` are preserved; remove them per-project with `codegraph uninit`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/OrangeKing-Leo/devcontainer-features/blob/main/src/codegraph/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
