# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin that gives Claude a voice. When Claude finishes work, it speaks to the user via system TTS or Microsoft Edge neural voices. Zero dependencies beyond optional `pip install edge-tts`.

## Architecture

Three-hook system:

1. **SessionStart** (sync, Node.js) — `hooks/session-start.js` outputs plain text voice instruction to stdout. Claude Code injects it as a system-reminder so Claude knows to include `<voice>` tags.
2. **Stop** (async) — `hooks/extract-and-speak` reads the transcript JSONL, extracts the last `<voice>` tag, speaks it via `scripts/speak.sh`.
3. **Notification** (async) — `hooks/notify-speak` fires on permission/idle/dialog events, picks a personality fallback message, speaks it.

The `<voice>` tag protocol is the core contract: Claude writes `<voice>max 15 words</voice>`, the Stop hook extracts and speaks it.

**TTS routing:** `speak.sh` reads the engine from config, routes to `speak-edge.py` (Edge TTS → MP3 → platform player) or platform builtin (Windows SAPI via `speak.ps1`, macOS `say`, Linux `espeak`).

## Key Files

| File | Purpose |
|------|---------|
| `hooks/hooks.json` | Hook definitions — entry point for Claude Code |
| `hooks/session-start.js` | **Primary** SessionStart hook (Node.js, plain text output) |
| `hooks/session-start` | Legacy bash version (not used, kept as reference) |
| `hooks/extract-and-speak` | Stop hook — transcript parsing and voice extraction |
| `hooks/notify-speak` | Notification hook — fallback personality messages |
| `hooks/run-hook.cmd` | Polyglot batch+bash wrapper for cross-platform hook execution |
| `scripts/speak.sh` | Central TTS router |
| `scripts/speak-edge.py` | Edge TTS engine (async, generates MP3) |
| `scripts/speak.ps1` | Windows SAPI builtin TTS |
| `scripts/play-audio.ps1` | Windows MP3 playback (WPF MediaPlayer) |
| `scripts/detect-python.sh` | Cross-platform Python 3 detection (sets `$PYTHON`) |
| `config/voice-config.json` | User settings (personality, engine, volume, muted, etc.) |
| `config/personalities.json` | Personality presets with style instructions and fallback messages |
| `commands/voice.md` | `/voice` slash command definition |

## Critical Conventions

- **SessionStart must use Node.js with plain text output.** Bash hooks fail on Windows (CRLF, JSON escaping). JSON `additionalContext` from plugin hooks is broken (Claude Code bug #16538). Plain text stdout is the reliable path.
- **Version bump required for cache refresh.** Claude Code caches plugins by version. Changing files without bumping `.claude-plugin/plugin.json` version means users won't get updates.
- All bash scripts use `set -euo pipefail`. Python is used for JSON parsing (no jq dependency).
- `detect-python.sh` must be sourced before any Python usage — it sets `$PYTHON` to whichever binary works.
- Mute check goes at the top of every hook (early exit if `config.muted` is true).
- `scripts/` has duplicate versions of some hook scripts (originals before `hooks/` directory was created). The `hooks/` versions are canonical.

## Testing

No automated test suite. Manual testing:

```bash
# Test SessionStart hook output
node hooks/session-start.js

# Test TTS directly
bash scripts/speak.sh "Hello world" 100 2

# Test Edge TTS
python scripts/speak-edge.py "Hello world"

# Test the /voice command in Claude Code
/voice test
```

## Plugin Packaging

- Manifest: `.claude-plugin/plugin.json` (name, version, author)
- Installed via `enabledPlugins` in `~/.claude/settings.json`
- Cache location: `~/.claude/plugins/cache/aryanxpatel/hey-claude/<version>/`
- No npm/pip dependencies bundled — `edge-tts` is user-installed optional
