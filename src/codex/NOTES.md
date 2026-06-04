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
