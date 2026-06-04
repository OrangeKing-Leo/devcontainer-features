## Scope

Metadata-only feature — `install.sh` is a no-op. VS Code reads `customizations.vscode.extensions` from the feature manifest and installs the listed extensions on attach.

## Dependencies

Declares `dependsOn` on the [`dev-extensions`](../dev-extensions) feature. The devcontainer CLI will auto-install `dev-extensions` even if the user only lists `frontend-extensions`. The intent is to layer language-specific tools on top of the base "every developer wants this" bundle.

## Editor compatibility

- **VS Code, Cursor, GitHub Codespaces** — all listed extensions install automatically.
- **Pure CLI / SSH** — feature is a no-op.
- **JetBrains Gateway / other editors** — ignored.

## Why not include ESLint / Prettier / Vetur?

- **ESLint / Prettier** — both are projects-specific tools requiring config files (`.eslintrc.*`, `.prettierrc`) and locally-installed deps. Forcing extensions when there's no config produces noisy errors. Add them to your own `devcontainer.json` if your project uses them.
- **Vetur** — superseded by Volar for Vue 3. Do not enable both at the same time.

## Adding more extensions

Add to your own `devcontainer.json` `customizations.vscode.extensions`; they merge with this feature's list:

```jsonc
"customizations": {
    "vscode": {
        "extensions": [
            "dbaeumer.vscode-eslint",
            "esbenp.prettier-vscode"
        ]
    }
}
```
