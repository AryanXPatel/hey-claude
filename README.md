# Hey Claude

**Your AI agent talks to you.**

A Claude Code plugin that gives Claude a voice. Instead of staring at your terminal waiting, Claude literally speaks to you — tells you what it did, what it needs, and when it's your turn.

## Why?

You're working on something else. Claude finishes a complex refactor. Instead of a silent cursor blink, you hear:

> *"Auth refactor done. Changed 3 files. Your turn."*

You're grabbing coffee. Claude needs permission:

> *"Hey, need your go-ahead to run a shell command."*

You're in another window. Claude hit an error:

> *"Hit a type error in dashboard. Need your eyes on this."*

**Zero cost. Works with built-in system TTS or Microsoft's neural voices via edge-tts (free, no API key).**

## How It Works

1. When a session starts, Claude gets a tiny instruction to include `<voice>` tags in its responses
2. Claude naturally writes `<voice>short contextual message</voice>` as it works
3. When Claude stops, a hook extracts the voice tag and speaks it
4. For system notifications (permissions, dialogs), fallback messages play automatically

```
Claude finishes work
    → Stop hook fires
    → Reads transcript, finds: <voice>Dashboard done. Tests passing.</voice>
    → Speaks: "Dashboard done. Tests passing."
    → You hear it from across the room
```

## Install

Add `"hey-claude@aryanxpatel": true` to your `enabledPlugins` in `~/.claude/settings.json`.

Then run `/voice setup` in Claude Code to pick your personality, TTS engine, and voice.

## TTS Engines

| Engine | Quality | Latency | Offline | Setup |
|--------|---------|---------|---------|-------|
| **Built-in** (default) | Basic | Instant | Yes | Zero — uses Windows SAPI, macOS `say`, Linux `espeak` |
| **Edge TTS** (recommended) | Neural, human-like | ~1 second | No (needs internet) | `pip install edge-tts` |

### Edge TTS Voices

Edge TTS gives you access to Microsoft's neural voices — the same ones used by Edge browser's "Read Aloud". 300+ voices in 70+ languages, completely free, no API key.

Best English male voices:

| Voice | Vibe |
|-------|------|
| `en-US-ChristopherNeural` | Clear, authoritative, JARVIS-like |
| `en-US-AndrewNeural` | Smooth, professional presenter |
| `en-US-GuyNeural` | Warm, natural, conversational |
| `en-US-BrianNeural` | Casual, friendly, younger |
| `en-US-RogerNeural` | Deep, commanding |

To install: `pip install edge-tts`

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
| `/voice setup` | Interactive setup wizard (personality, engine, voice, speed, volume) |
| `/voice test` | Test current voice |
| `/voice mute` | Mute (DND mode) |
| `/voice unmute` | Unmute |
| `/voice personality jarvis` | Switch personality |
| `/voice volume 80` | Set volume (0-100) |
| `/voice speed 3` | Set speech rate (-5 to 5) |
| `/voice voices` | List available voices |
| `/voice voice <name>` | Set specific voice |

## Cross-Platform

| Platform | Built-in Engine | Edge TTS |
|----------|----------------|----------|
| Windows | System.Speech (SAPI) | Yes |
| macOS | `say` command | Yes |
| Linux | `espeak` / `piper` / `festival` | Yes (needs `mpv` or `ffplay` for MP3) |

### Linux Setup
```bash
# Built-in TTS
sudo apt install espeak

# Edge TTS (recommended)
pip install edge-tts
sudo apt install mpv    # for MP3 playback
```

## Configuration

Settings are stored in `config/voice-config.json`:

```json
{
  "personality": "casual",
  "engine": "builtin",
  "volume": 100,
  "rate": 2,
  "muted": false,
  "voice": null,
  "edge_voice": "en-US-ChristopherNeural",
  "edge_rate": "+10%"
}
```

| Field | Description | Values |
|-------|-------------|--------|
| `personality` | Voice personality preset | `casual`, `jarvis`, `professional`, or custom |
| `engine` | TTS engine to use | `builtin` or `edge-tts` |
| `volume` | Playback volume | 0-100 |
| `rate` | Speech rate (built-in only) | -5 to 5 |
| `voice` | Specific built-in voice name | System voice name or `null` for default |
| `edge_voice` | Edge TTS voice ID | e.g., `en-US-ChristopherNeural` |
| `edge_rate` | Edge TTS speed adjustment | e.g., `+10%`, `-20%`, `+0%` |

### Custom Personality

Add your own personality to `config/personalities.json`:

```json
{
  "pirate": {
    "instruction": "Speak like a friendly pirate. Use 'Arr', 'matey', 'ahoy'.",
    "edge_voice": "en-US-RogerNeural",
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
    → Speaks via selected TTS engine

Notification hook (async, fallback)
    → Fires on permission/idle/dialog events
    → Picks personality-appropriate fallback message
    → Speaks via selected TTS engine
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Ideas for future versions:
- **Kokoro TTS** integration (offline neural TTS — best of both worlds)
- **Sound effects** before voice (subtle chime + speech)
- **Quiet hours** (auto-mute during certain times)
- **Voice input** (talk back to Claude)
- **Multi-language** support
- **Voice cloning** (use your own voice)

## License

MIT
