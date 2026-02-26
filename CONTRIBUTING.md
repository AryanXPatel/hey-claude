# Contributing to Hey Claude

Thanks for your interest in contributing! Here's how to get started.

## Development Setup

1. Fork and clone the repo
2. Install the plugin locally:
   ```bash
   claude plugin add --source local /path/to/hey-claude
   ```
3. Test with `/voice test`

## Project Structure

```
hey-claude/
  .claude-plugin/
    plugin.json          # Plugin manifest
  hooks/
    hooks.json           # Hook definitions (SessionStart, Stop, Notification)
  scripts/
    speak.ps1            # Windows TTS (PowerShell)
    speak.sh             # Cross-platform TTS wrapper
    extract-and-speak.sh # Stop hook: parse transcript → extract <voice> → speak
    notify-speak.sh      # Notification hook: fallback messages → speak
    voice-instruction.sh # SessionStart hook: inject voice instruction
  config/
    voice-config.json    # User preferences
    personalities.json   # Built-in + custom personalities
  commands/
    voice.md             # /voice slash command
```

## Adding a Personality

1. Add your personality to `config/personalities.json`
2. Include: `instruction` (style guide) and `fallback_messages` (per event type)
3. Test with `/voice personality your-name` then `/voice test`
4. Submit a PR!

## Adding Platform Support

TTS is handled in `scripts/speak.sh`. To add a new platform or TTS engine:

1. Add a new case in the platform detection (`uname -s`)
2. Map the volume/rate parameters to the engine's format
3. Test on the target platform
4. Update the README

## Guidelines

- Keep scripts POSIX-compatible where possible
- Test on Windows (primary platform) before submitting
- Don't add external dependencies without discussion
- Keep voice messages under 15 words
- Personalities should be fun but professional enough for work

## Reporting Issues

Include:
- Platform (Windows/macOS/Linux) and version
- Claude Code version
- Output of `/voice` (current config)
- What you expected vs what happened
