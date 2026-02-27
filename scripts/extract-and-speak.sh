#!/usr/bin/env bash
# extract-and-speak.sh — Stop hook (async)
# Reads the transcript, extracts the last <voice> tag, and speaks it.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-python.sh"

CONFIG_FILE="$SCRIPT_DIR/../config/voice-config.json"

# Check if muted
if [ -f "$CONFIG_FILE" ]; then
    MUTED=$($PYTHON -c "import json; print(json.load(open('$CONFIG_FILE')).get('muted', False))" 2>/dev/null || echo "False")
    if [ "$MUTED" = "True" ] || [ "$MUTED" = "true" ]; then
        exit 0
    fi
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract transcript path from hook input JSON
TRANSCRIPT_PATH=$(echo "$INPUT" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('transcript_path', ''))
" 2>/dev/null || echo "")

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    exit 0
fi

# Read the last few lines of the transcript (JSONL format) and look for <voice> tags
# We search the last 5 lines in case there are tool calls mixed in
VOICE_TEXT=$(tail -20 "$TRANSCRIPT_PATH" | $PYTHON -c "
import sys, re, json

voice_text = ''
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        entry = json.loads(line)
        # Handle different transcript formats
        content = ''
        if isinstance(entry, dict):
            # Try common content field names
            content = entry.get('content', '')
            if isinstance(content, list):
                # Content might be a list of blocks
                for block in content:
                    if isinstance(block, dict):
                        text = block.get('text', '')
                        if text:
                            content = text
                            break
                else:
                    content = str(content)
            msg = entry.get('message', '')
            if isinstance(msg, dict):
                msg = msg.get('content', '')
            if isinstance(msg, list):
                for block in msg:
                    if isinstance(block, dict):
                        text = block.get('text', '')
                        if text:
                            msg = text
                            break
            content = str(content) + ' ' + str(msg)
        # Extract <voice> tag
        matches = re.findall(r'<voice>(.*?)</voice>', str(content), re.DOTALL)
        if matches:
            voice_text = matches[-1].strip()
    except (json.JSONDecodeError, KeyError, TypeError):
        # Try raw text matching as fallback
        matches = re.findall(r'<voice>(.*?)</voice>', line, re.DOTALL)
        if matches:
            voice_text = matches[-1].strip()

if voice_text:
    # Truncate to ~20 words max for speech
    words = voice_text.split()
    if len(words) > 20:
        voice_text = ' '.join(words[:20])
    print(voice_text)
" 2>/dev/null || echo "")

if [ -z "$VOICE_TEXT" ]; then
    exit 0
fi

# Read config for volume, rate, voice
VOLUME=100
RATE=2
VOICE=""
if [ -f "$CONFIG_FILE" ]; then
    eval "$($PYTHON -c "
import json
c = json.load(open('$CONFIG_FILE'))
print(f'VOLUME={c.get(\"volume\", 100)}')
print(f'RATE={c.get(\"rate\", 2)}')
v = c.get('voice', '') or ''
print(f'VOICE={v}')
" 2>/dev/null || echo "")"
fi

# Speak it
bash "$SCRIPT_DIR/speak.sh" "$VOICE_TEXT" "$VOLUME" "$RATE" "$VOICE"
