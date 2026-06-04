#!/usr/bin/env bash
set -euo pipefail

# frontend-extensions is metadata-only: VS Code extensions are declared in
# devcontainer-feature.json under customizations.vscode.extensions. VS Code
# installs them after the container starts. Nothing to do at build time.

echo "frontend-extensions feature: no install actions (extensions declared in manifest)."
