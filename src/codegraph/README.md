
# CodeGraph CLI (codegraph)

Installs the CodeGraph CLI (@colbymchenry/codegraph) — a pre-indexed code knowledge graph for Claude Code, Codex, Cursor, Gemini, OpenCode, Antigravity, Kiro, and Hermes Agent.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codegraph:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @colbymchenry/codegraph to install (npm dist-tag or semver, e.g. 'latest', '1.0.0'). | string | latest |
| installNode | Install Node.js (via NodeSource) if 'node' is not already on PATH. Disable if you supply Node yourself. | boolean | true |
| nodeVersion | Major Node.js version to install when installNode is true (e.g. '18', '20', '22'). | string | 20 |
| installAliases | Install shell aliases (bash + zsh) system-wide: 'cgi' => 'codegraph install' (wire MCP into installed agents) and 'cgii' => 'codegraph init -i' (initialize and index a project). | boolean | false |

## OS Support

This feature targets Debian/Ubuntu based images (uses `apt-get`). Tested on:

- `mcr.microsoft.com/devcontainers/base:ubuntu`
- `mcr.microsoft.com/devcontainers/base:debian`

Not supported on Alpine.

## Requirements

- Node.js 18 or newer. If `node` is not on `PATH`, the feature installs Node via NodeSource (controlled by `installNode` / `nodeVersion`).
- Outbound access to `registry.npmjs.org` (and `deb.nodesource.com` when Node is auto-installed).

## Wiring agents

After the container is built, run `codegraph install` inside the container to wire CodeGraph's MCP server into whichever agents are present (Claude Code, Codex, Cursor, etc.). This feature deliberately does not run that at build time — wiring writes to the user's home (`~/.claude`, `~/.codex`, …), which is often mounted as a named volume that doesn't exist yet during image build.

```bash
codegraph install            # auto-detect all installed agents
codegraph install --target claude-code --yes   # just one, non-interactive
```

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

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
