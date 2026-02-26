# Hey Claude 🔊

**Your AI agent talks to you.**

A Claude Code plugin that gives Claude a voice. Instead of staring at your terminal waiting, Claude literally speaks to you — tells you what it did, what it needs, and when it's your turn.

https://github.com/user-attachments/assets/demo.mp4

## Why?

You're working on something else. Claude finishes a complex refactor. Instead of a silent cursor blink, you hear:

> *"Auth refactor done. Changed 3 files. Your turn."*

You're grabbing coffee. Claude needs permission:

> *"Hey, need your go-ahead to run a shell command."*

You're in another window. Claude hit an error:

> *"Hit a type error in dashboard. Need your eyes on this."*

**No API calls. No external services. Zero cost. Works offline.**

## How It Works

1. When a session starts, Claude gets a tiny instruction to include `<voice>` tags in its responses
2. Claude naturally writes `<voice>short contextual message</voice>` as it works
3. When Claude stops, a hook extracts the voice tag and speaks it through your system's built-in TTS
4. For system notifications (permissions, dialogs), fallback messages play automatically

```
Claude finishes work
    → Stop hook fires
    → Reads transcript, finds: <voice>Dashboard done. Tests passing.</voice>
    → Speaks: "Dashboard done. Tests passing."
    → You hear it from across the room
```

## Install

```bash
claude plugin add --source url https://github.com/AryanXPatel/hey-claude.git
```

Then run `/voice setup` in Claude Code to pick your personality and test the voice.

## Personalities

### Casual Buddy (default)
> *"Hey, auth refactor done. 3 files changed."*
> *"Need your go-ahead on this."*
> *"Done! What's next?"*

### JARVIS
> *"Sir, refactoring complete. 3 files modified."*
> *"Authorization required, sir."*
> *"All tasks completed. Awaiting instructions, sir."*

### Professional
> *"Auth refactor complete. 3 files changed."*
> *"Permission needed to proceed."*
> *"Task complete. Ready for review."*

### Custom
Create your own personality with custom messages. See [Configuration](#configuration).

## Commands

| Command | Description |
|---------|-------------|
| `/voice` | Show current settings |
| `/voice setup` | Interactive setup wizard |
| `/voice test` | Test current voice |
| `/voice mute` | Mute (DND mode) |
| `/voice unmute` | Unmute |
| `/voice personality jarvis` | Switch personality |
| `/voice volume 80` | Set volume (0-100) |
| `/voice speed 3` | Set speech rate (-5 to 5) |
| `/voice voices` | List available system voices |

## Cross-Platform

| Platform | TTS Engine | Built-in? |
|----------|-----------|-----------|
| Windows | System.Speech (SAPI) | Yes |
| macOS | `say` command | Yes |
| Linux | `espeak` / `piper` / `festival` | `espeak` usually pre-installed |

### Linux Setup
```bash
# Ubuntu/Debian
sudo apt install espeak

# For better voices (neural TTS)
pip install piper-tts
```

## Configuration

Settings are stored in `config/voice-config.json`:

```json
{
  "personality": "casual",
  "volume": 100,
  "rate": 2,
  "muted": false,
  "voice": null
}
```

### Custom Personality

Add your own personality to `config/personalities.json`:

```json
{
  "pirate": {
    "instruction": "Speak like a friendly pirate. Use 'Arr', 'matey', 'ahoy'.",
    "fallback_messages": {
      "permission_prompt": ["Arr, need yer permission to proceed, cap'n!"],
      "idle_prompt": ["All done, matey! Yer turn at the helm."],
      "elicitation_dialog": ["Ahoy! Got a choice for ye, cap'n."]
    }
  }
}
```

Then: `/voice personality pirate`

## Architecture

```
SessionStart hook
    → Injects voice instruction into Claude's context
    → Claude writes <voice> tags naturally in responses

Stop hook (async)
    → Reads transcript
    → Extracts last <voice> tag
    → Speaks via platform TTS

Notification hook (async, fallback)
    → Fires on permission/idle/dialog events
    → Picks personality-appropriate fallback message
    → Speaks via platform TTS
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Ideas for v2:
- **Edge TTS** integration (Microsoft neural voices — way more natural, still free)
- **Sound effects** before voice (subtle chime + speech)
- **Quiet hours** (auto-mute during certain times)
- **Voice input** (talk back to Claude)
- **Multi-language** support (Edge TTS supports 300+ voices, 70+ languages)

## License

MIT
