# Common Dev VS Code Extensions (`dev-extensions`)

Installs [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) — line-level git blame, file history, and code authorship insights inside the VS Code editor.

Only affects VS Code / Cursor / Codespaces. Pure CLI users see no effect.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/dev-extensions:1": {}
}
```

## Options

No options. The feature declares a single extension in `customizations.vscode.extensions` and VS Code installs it on attach.

## Bundled extensions

- `eamodio.gitlens` — hover over any line to see who last changed it, when, and in which commit; built-in file history, blame annotations, and side-by-side diff against any revision.
- `ms-ceintl.vscode-language-pack-zh-hans` — Simplified Chinese (简体中文) UI translation for VS Code. To activate, run the command `Configure Display Language` and pick `zh-cn`, then reload.
