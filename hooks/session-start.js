#!/usr/bin/env node
// session-start.js — SessionStart hook for hey-claude
// Node.js version for reliable cross-platform context injection.
// Bash-based hooks have Windows issues (CRLF, JSON escaping, Git Bash paths).

const fs = require('fs');
const path = require('path');

const PLUGIN_ROOT = path.resolve(__dirname, '..');
const CONFIG_FILE = path.join(PLUGIN_ROOT, 'config', 'voice-config.json');
const PERSONALITIES_FILE = path.join(PLUGIN_ROOT, 'config', 'personalities.json');

function readJSON(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

function main() {
  const config = readJSON(CONFIG_FILE) || {};
  const personalities = readJSON(PERSONALITIES_FILE) || {};

  // If muted, exit silently
  if (config.muted) {
    process.exit(0);
  }

  const personality = config.personality || 'casual';
  const personData = personalities[personality] || personalities.casual || {};
  const style = personData.instruction || 'Speak casually and friendly.';

  const voiceInstruction = `VOICE NOTIFICATION SYSTEM ACTIVE (hey-claude plugin):
When you finish significant work, encounter errors, need user input, or want to notify the user of something important, include a <voice> tag in your response with a brief spoken message.

Format: <voice>your short message here</voice>

Rules:
- Maximum 15 words
- Speak naturally as if talking to the user
- Be specific about what you did or what you need
- Style: ${style}
- Include at most ONE <voice> tag per response
- Only include when there is something meaningful to say

Examples:
- <voice>Refactored the auth module. Changed 3 files. Your turn.</voice>
- <voice>Hit a type error in dashboard. Need your eyes on this.</voice>
- <voice>Got two approaches for the API. Come pick one.</voice>`;

  // Plain text output — proven to work reliably across all platforms.
  // Claude Code captures stdout and injects it as a system-reminder.
  // JSON additionalContext from plugin hooks is broken (Claude Code bug #16538).
  process.stdout.write(voiceInstruction);
  process.exit(0);
}

main();
