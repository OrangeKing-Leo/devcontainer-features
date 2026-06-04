#!/usr/bin/env bash
set -euo pipefail

# dev-extensions is a metadata-only feature: the VS Code extensions it
# contributes are declared in devcontainer-feature.json under
# customizations.vscode.extensions, and VS Code installs them after the
# container starts. install.sh has nothing to do at build time.

echo "dev-extensions feature: no install actions (extensions declared in manifest)."
