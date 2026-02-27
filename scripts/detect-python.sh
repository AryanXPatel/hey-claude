#!/usr/bin/env bash
# detect-python.sh — Cross-platform Python binary detection
# Sources by other scripts: source "$(dirname "${BASH_SOURCE[0]}")/detect-python.sh"
# Sets $PYTHON to the working Python 3 binary, or exits with error.

if [ -n "${PYTHON:-}" ]; then
    # Already detected, skip
    return 0 2>/dev/null || true
fi

PYTHON=""

# python3 is standard on Linux/macOS
# But on Windows it's often a Microsoft Store stub that exits non-zero
if command -v python3 &>/dev/null && python3 -c "pass" &>/dev/null 2>&1; then
    PYTHON="python3"
# python is standard on Windows, and some Linux distros alias it to python3
elif command -v python &>/dev/null && python -c "pass" &>/dev/null 2>&1; then
    PYTHON="python"
fi

if [ -z "$PYTHON" ]; then
    echo "hey-claude: Python not found. Install Python 3: https://python.org" >&2
    exit 1
fi
