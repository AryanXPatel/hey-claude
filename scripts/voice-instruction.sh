#!/usr/bin/env bash
# voice-instruction.sh — SessionStart hook
# Outputs the voice instruction for Claude based on the active personality.
# Claude Code feeds this output back into context.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
CONFIG_FILE="$CONFIG_DIR/voice-config.json"
PERSONALITIES_FILE="$CONFIG_DIR/personalities.json"

# Check if muted
if [ -f "$CONFIG_FILE" ]; then
    MUTED=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('muted', False))" 2>/dev/null || echo "False")
    if [ "$MUTED" = "True" ] || [ "$MUTED" = "true" ]; then
        exit 0
    fi
    PERSONALITY=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('personality', 'casual'))" 2>/dev/null || echo "casual")
else
    PERSONALITY="casual"
fi

# Get personality style instruction
STYLE=""
if [ -f "$PERSONALITIES_FILE" ]; then
    STYLE=$(cat "$PERSONALITIES_FILE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
p = data.get('$PERSONALITY', data.get('casual', {}))
print(p.get('instruction', ''))
" 2>/dev/null || echo "")
fi

# Output the voice instruction — Claude Code injects this into context
cat <<EOF
VOICE NOTIFICATION SYSTEM ACTIVE (hey-claude plugin):
When you finish significant work, encounter errors, need user input, or want to notify the user of something important, include a <voice> tag in your response with a brief spoken message.

Format: <voice>your short message here</voice>

Rules:
- Maximum 15 words
- Speak naturally as if talking to the user
- Be specific about what you did or what you need
- Style: ${STYLE:-Speak casually and friendly.}
- Include at most ONE <voice> tag per response
- Only include when there is something meaningful to say

Examples:
- <voice>Refactored the auth module. Changed 3 files. Your turn.</voice>
- <voice>Hit a type error in dashboard. Need your eyes on this.</voice>
- <voice>Got two approaches for the API. Come pick one.</voice>
EOF
