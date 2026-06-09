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

## Install location & auto-update

Claude Code is installed under a per-user npm prefix (`~/.npm-global`) rather than the system-wide `/usr/lib/node_modules`. The feature writes `~/.npmrc` with `prefix=${HOME}/.npm-global` and adds `$HOME/.npm-global/bin` to `PATH` via `/etc/profile.d/claude-code-path.sh`.

The reason: Claude Code's built-in auto-updater writes to its install directory. A root-owned system install leaves the updater unable to write as the (non-root) remote user. The user-local prefix fixes this without granting the remote user write access to system paths.

To pin a specific version, set the `version` option (`latest` by default) — but note that the auto-updater may still bump it at runtime.

## Per-user configuration

Claude Code reads `~/.claude/settings.json` for permissions / hooks / preferences. This feature deliberately does not seed that file — manage it yourself (commit a template in your project, mount a named volume across rebuilds, or run `claude` interactively to let it write its own).
