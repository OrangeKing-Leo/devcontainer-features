#!/bin/bash

set -e

# Test if Codex CLI is installed
if ! command -v codex &> /dev/null; then
    echo "codex command not found"
    exit 1
fi

# Test version output
if ! codex --version | grep -qi "codex"; then
    echo "codex version check failed"
    exit 1
fi

echo "Codex CLI installation test passed!"
exit 0
