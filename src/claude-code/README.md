
# Claude Code CLI (claude-code)

Installs Anthropic's Claude Code CLI (@anthropic-ai/claude-code) via npm, with optional Node.js auto-install and a starter settings.json.

## Example Usage

```json
"features": {
    "ghcr.io/OrangeKing-Leo/devcontainer-features/claude-code:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @anthropic-ai/claude-code to install (npm dist-tag or semver, e.g. 'latest', '1.0.0'). | string | latest |
| installNode | Install Node.js (via NodeSource) if 'node' is not already on PATH. Disable if you supply Node yourself. | boolean | true |
| nodeVersion | Major Node.js version to install when installNode is true (e.g. '18', '20', '22'). | string | 20 |
| installSettings | Write a starter ~/.claude/settings.json for the remote user if one does not exist. | boolean | false |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`

## OS Support

This feature targets Debian/Ubuntu based images (uses `apt-get`). It has been tested against:

- `mcr.microsoft.com/devcontainers/base:ubuntu`
- `mcr.microsoft.com/devcontainers/base:debian`

It will **not** work on Alpine or other non-`apt` distributions.

## Requirements

- Node.js 18 or newer. If `node` is not on `PATH`, the feature installs Node via NodeSource (controlled by the `installNode` / `nodeVersion` options).
- Outbound network access to `registry.npmjs.org` (and `deb.nodesource.com` when Node is auto-installed).

## Authentication

No credentials are baked into the image. After the container starts, run:

```bash
claude login
```

to authenticate interactively. Credentials are stored under `~/.claude` for the remote user.

## Pinning the version

`CLAUDE_CODE_AUTO_UPDATE=0` is exported via `containerEnv` so the version installed at build time is not silently replaced at runtime. To upgrade, rebuild the container after bumping the `version` option.

## Known limitations

- The `installSettings` option will **not** overwrite an existing `~/.claude/settings.json`.
- When running as `root` (no remote user detected), the starter settings are written to `/root/.claude/settings.json`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/OrangeKing-Leo/devcontainer-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
