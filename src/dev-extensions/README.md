
# Common Dev VS Code Extensions (dev-extensions)

Installs GitLens (line-level git blame, file history, code authorship), the VS Code Simplified Chinese language pack, and Mermaid diagram rendering in the Markdown preview.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `eamodio.gitlens`
- `ms-ceintl.vscode-language-pack-zh-hans`
- `bierner.markdown-mermaid`

## Scope

Metadata-only feature — `install.sh` is a no-op. VS Code reads `customizations.vscode.extensions` from the feature manifest and installs GitLens after the container starts.

## Editor compatibility

- **VS Code, Cursor, GitHub Codespaces** — GitLens installs automatically.
- **Pure CLI / SSH** without a VS Code-family editor attached — feature is a no-op.
- **JetBrains Gateway / other editors** — ignores `customizations.vscode.*`; no effect.

## Why so few extensions?

By design. This feature only bundles GitLens because:

1. **Universal value** — every developer benefits from line-level blame, regardless of language.
2. **Zero side-effects** — GitLens doesn't change formatting, linting, or save behaviour.
3. **No opinion creep** — Prettier, ESLint, language servers, etc. belong to language-specific features (e.g. a frontend feature), not a base bundle.

To add more extensions, list them in your project's `devcontainer.json` under `customizations.vscode.extensions`; they merge with this feature's set.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
