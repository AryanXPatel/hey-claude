#!/usr/bin/env bash
# notify-speak.sh — Notification hook (async, fallback)
# Speaks the notification message with personality wrapper.
# Used when Claude doesn't include a <voice> tag (system notifications).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/voice-config.json"
PERSONALITIES_FILE="$SCRIPT_DIR/../config/personalities.json"

# Check if muted
if [ -f "$CONFIG_FILE" ]; then
    MUTED=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('muted', False))" 2>/dev/null || echo "False")
    if [ "$MUTED" = "True" ] || [ "$MUTED" = "true" ]; then
        exit 0
    fi
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract notification type and message
NOTIFICATION_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('notification_type', ''))
" 2>/dev/null || echo "")

NOTIFICATION_MSG=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('message', ''))
" 2>/dev/null || echo "")

if [ -z "$NOTIFICATION_TYPE" ]; then
    exit 0
fi

# Get personality and pick a fallback message
PERSONALITY="casual"
if [ -f "$CONFIG_FILE" ]; then
    PERSONALITY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('personality', 'casual'))" 2>/dev/null || echo "casual")
fi

# Try to get a personality-specific fallback message
SPEAK_TEXT=""
if [ -f "$PERSONALITIES_FILE" ]; then
    SPEAK_TEXT=$(python3 -c "
import json, random
personalities = json.load(open('$PERSONALITIES_FILE'))
p = personalities.get('$PERSONALITY', personalities.get('casual', {}))
fallbacks = p.get('fallback_messages', {})
messages = fallbacks.get('$NOTIFICATION_TYPE', [])
if messages:
    print(random.choice(messages))
" 2>/dev/null || echo "")
fi

# If no personality fallback, use the system notification message
if [ -z "$SPEAK_TEXT" ]; then
    SPEAK_TEXT="$NOTIFICATION_MSG"
fi

if [ -z "$SPEAK_TEXT" ]; then
    exit 0
fi

# Read config for volume, rate, voice
VOLUME=100
RATE=2
VOICE=""
if [ -f "$CONFIG_FILE" ]; then
    eval "$(python3 -c "
import json
c = json.load(open('$CONFIG_FILE'))
print(f'VOLUME={c.get(\"volume\", 100)}')
print(f'RATE={c.get(\"rate\", 2)}')
v = c.get('voice', '') or ''
print(f'VOICE={v}')
" 2>/dev/null || echo "")"
fi

# Speak it
bash "$SCRIPT_DIR/speak.sh" "$SPEAK_TEXT" "$VOLUME" "$RATE" "$VOICE"
