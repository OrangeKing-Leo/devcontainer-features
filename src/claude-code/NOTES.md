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

## Per-user configuration

Claude Code reads `~/.claude/settings.json` for permissions / hooks / preferences. This feature deliberately does not seed that file — manage it yourself (commit a template in your project, mount a named volume across rebuilds, or run `claude` interactively to let it write its own).
