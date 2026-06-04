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

## Per-user configuration

Codex reads `~/.codex/config.toml` for default `model`, `approval_policy`, `sandbox_mode`, etc. This feature does not seed that file — manage it yourself or let `codex` write its own on first run. See the [Codex docs](https://github.com/openai/codex) for the full schema.
