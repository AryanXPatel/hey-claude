#!/usr/bin/env bash
# speak.sh — Cross-platform TTS wrapper
# Usage: speak.sh "message" [volume] [rate] [voice]

set -euo pipefail

MESSAGE="${1:-}"
VOLUME="${2:-100}"
RATE="${3:-2}"
VOICE="${4:-}"

if [ -z "$MESSAGE" ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect platform and speak
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        # Windows — use PowerShell System.Speech
        powershell -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/speak.ps1" "$MESSAGE" "$VOLUME" "$RATE" "$VOICE"
        ;;
    Darwin)
        # macOS — use built-in 'say' command
        # Rate: say uses words-per-minute (default ~175), map our -5..5 scale
        SAY_RATE=$(( 175 + (RATE * 25) ))
        if [ -n "$VOICE" ] && [ "$VOICE" != "null" ]; then
            say -v "$VOICE" -r "$SAY_RATE" "$MESSAGE"
        else
            say -r "$SAY_RATE" "$MESSAGE"
        fi
        ;;
    Linux)
        # Linux — try espeak first, then piper, then festival
        if command -v espeak &>/dev/null; then
            ESPEAK_SPEED=$(( 160 + (RATE * 20) ))
            espeak -s "$ESPEAK_SPEED" -a "$VOLUME" "$MESSAGE" 2>/dev/null
        elif command -v piper &>/dev/null; then
            echo "$MESSAGE" | piper --output-raw 2>/dev/null | aplay -r 22050 -c 1 -f S16_LE -q 2>/dev/null
        elif command -v festival &>/dev/null; then
            echo "$MESSAGE" | festival --tts 2>/dev/null
        else
            echo "hey-claude: No TTS engine found. Install espeak: sudo apt install espeak" >&2
        fi
        ;;
    *)
        echo "hey-claude: Unsupported platform: $(uname -s)" >&2
        ;;
esac
