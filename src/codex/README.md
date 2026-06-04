
# OpenAI Codex CLI (codex)

Installs OpenAI's Codex CLI (@openai/codex) via npm, with optional Node.js auto-install and a starter config.toml.

## Example Usage

```json
"features": {
    "ghcr.io/OrangeKing-Leo/devcontainer-features/codex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @openai/codex to install (npm dist-tag or semver, e.g. 'latest', '0.20.0'). | string | latest |
| installNode | Install Node.js (via NodeSource) if 'node' is not already on PATH. Disable if you supply Node yourself. | boolean | true |
| nodeVersion | Major Node.js version to install when installNode is true (e.g. '18', '20', '22'). | string | 20 |
| installConfig | Write a starter ~/.codex/config.toml for the remote user if one does not exist. | boolean | false |

## Customizations

### VS Code Extensions

- `openai.chatgpt`

## OS Support

Targets Debian/Ubuntu based images (uses `apt-get`). Tested on:

- `mcr.microsoft.com/devcontainers/base:ubuntu`
- `mcr.microsoft.com/devcontainers/base:debian`

Not supported on Alpine.

## Requirements

- Node.js 18 or newer. If `node` is not on `PATH`, the feature installs Node via NodeSource (controlled by `installNode` / `nodeVersion`).
- Outbound access to `registry.npmjs.org` (and `deb.nodesource.com` when Node is auto-installed).

## Authentication

No credentials are baked into the image. After the container starts, run:

```bash
codex login
```

to authenticate interactively (ChatGPT account or `OPENAI_API_KEY`). Credentials are stored under `~/.codex` for the remote user. To use an API key non-interactively, set `OPENAI_API_KEY` via your `devcontainer.json` `remoteEnv` / `containerEnv`.

## Starter config

When `installConfig` is true, a commented `~/.codex/config.toml` is written (only if absent). Uncomment lines to set the default `model`, `approval_policy`, or `sandbox_mode`. See the [Codex docs](https://github.com/openai/codex) for the full schema.

## Known limitations

- `installConfig` will **not** overwrite an existing `~/.codex/config.toml`.
- When running as `root` (no remote user detected), the starter config is written to `/root/.codex/config.toml`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/OrangeKing-Leo/devcontainer-features/blob/main/src/codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
