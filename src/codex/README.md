
# OpenAI Codex CLI (codex)

Installs the OpenAI Codex CLI globally

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `openai.chatgpt`

# Using Codex in devcontainers

## Requirements

This feature requires Node.js and npm to be available in the container. You need to either:

1. Use a base container image that includes Node.js, or
2. Add the Node.js feature to your devcontainer.json
3. Let this feature attempt to install Node.js automatically (best-effort, works on Debian/Ubuntu, Alpine, Fedora, RHEL, and CentOS)

Note: When auto-installing Node.js, a compatible LTS version (Node.js 22.x) will be used, since `@openai/codex` requires Node.js 20 or newer.

## Recommended configuration

For most setups, we recommend explicitly adding both features:

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {}
}
```

## Using with containers that already have Node.js

If your container already has Node.js installed (for example, a container based on a Node.js image or one using nvm), you can use the Codex feature directly without adding the Node.js feature:

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/codex:1": {}
}
```

## Using with nvm

When using with containers that have nvm pre-installed, you can use the Codex feature directly, and it will use the existing Node.js installation.

## Authentication

No credentials are baked into the image. After the container starts, run `codex login` once to authenticate (ChatGPT account), or set `OPENAI_API_KEY` via `remoteEnv` / `containerEnv` in your devcontainer.json.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
