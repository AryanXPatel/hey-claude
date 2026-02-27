#!/usr/bin/env bash
# speak.sh — Cross-platform TTS wrapper with engine selection
# Usage: speak.sh "message" [volume] [rate] [voice] [engine] [edge_voice] [edge_rate]

set -euo pipefail

MESSAGE="${1:-}"
VOLUME="${2:-100}"
RATE="${3:-2}"
VOICE="${4:-}"
ENGINE="${5:-builtin}"
EDGE_VOICE="${6:-en-US-ChristopherNeural}"
EDGE_RATE="${7:-+10%}"

if [ -z "$MESSAGE" ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-python.sh"

# If no engine passed, try to read from config
if [ "$ENGINE" = "builtin" ] && [ -f "$SCRIPT_DIR/../config/voice-config.json" ]; then
    CONFIG_ENGINE=$($PYTHON -c "import json; print(json.load(open('$SCRIPT_DIR/../config/voice-config.json')).get('engine', 'builtin'))" 2>/dev/null || echo "builtin")
    if [ "$CONFIG_ENGINE" = "edge-tts" ]; then
        ENGINE="edge-tts"
        EDGE_VOICE=$($PYTHON -c "import json; print(json.load(open('$SCRIPT_DIR/../config/voice-config.json')).get('edge_voice', 'en-US-ChristopherNeural'))" 2>/dev/null || echo "en-US-ChristopherNeural")
        EDGE_RATE=$($PYTHON -c "import json; print(json.load(open('$SCRIPT_DIR/../config/voice-config.json')).get('edge_rate', '+10%'))" 2>/dev/null || echo "+10%")
    fi
fi

# Route to the right engine
if [ "$ENGINE" = "edge-tts" ]; then
    # Use edge-tts (Microsoft neural voices)
    $PYTHON "$SCRIPT_DIR/speak-edge.py" "$MESSAGE" "$EDGE_VOICE" "$EDGE_RATE" "$VOLUME" 2>/dev/null \
        || {
            # Fallback to built-in if edge-tts fails
            echo "hey-claude: edge-tts failed, falling back to built-in TTS" >&2
            ENGINE="builtin"
        }
fi

# Built-in TTS (fallback or primary)
if [ "$ENGINE" = "builtin" ]; then
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            powershell -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/speak.ps1" "$MESSAGE" "$VOLUME" "$RATE" "$VOICE"
            ;;
        Darwin)
            SAY_RATE=$(( 175 + (RATE * 25) ))
            if [ -n "$VOICE" ] && [ "$VOICE" != "null" ]; then
                say -v "$VOICE" -r "$SAY_RATE" "$MESSAGE"
            else
                say -r "$SAY_RATE" "$MESSAGE"
            fi
            ;;
        Linux)
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
fi
