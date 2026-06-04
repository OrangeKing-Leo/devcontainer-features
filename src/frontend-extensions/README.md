# Frontend (Vue & React) VS Code Extensions (`frontend-extensions`)

Adds syntax highlighting / language support for common frontend stacks. Layered on top of [`dev-extensions`](../dev-extensions) (automatically pulled in via `dependsOn`).

Only affects VS Code / Cursor / Codespaces.

## Example Usage

```json
"features": {
    "ghcr.io/orangeking-leo/devcontainer-features/frontend-extensions:1": {}
}
```

`dev-extensions` (GitLens + Simplified Chinese pack) is installed automatically as a dependency — you don't need to list it.

## Options

No options.

## Bundled extensions

- `vue.volar` — official Vue 3 Language Tools (Volar): `.vue` SFC syntax highlight, template / script / style support.
- `styled-components.vscode-styled-components` — syntax highlight + intellisense for CSS-in-JS template literals (`` styled.div`...` ``) common in React.
- `bradlc.vscode-tailwindcss` — Tailwind CSS class autocomplete + hover preview; widely used in both Vue and React projects.

## Notes on React/JSX/TSX

React / JSX / TSX are **already handled by VS Code's built-in TypeScript language server** — no extension is needed for highlighting or basic IntelliSense. This feature only adds extensions for things VS Code does not cover natively (Vue, CSS-in-JS, Tailwind).
