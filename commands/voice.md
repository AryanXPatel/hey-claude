---
name: voice
description: Configure hey-claude voice notifications — test voice, switch personality, mute/unmute, adjust settings
user_invocable: true
---

# Hey Claude — Voice Control

You are managing the hey-claude voice notification plugin. The user wants to configure their voice settings.

## Configuration Files

- **Voice config:** `config/voice-config.json` (in the hey-claude plugin directory)
- **Personalities:** `config/personalities.json` (in the hey-claude plugin directory)
- **TTS script:** `scripts/speak.sh` (cross-platform TTS)

## Available Subcommands

Parse the user's arguments to determine what they want:

### `/voice` (no args) — Show Status
Read `voice-config.json` and display:
- Current personality (casual/jarvis/professional/custom)
- Volume level (0-100)
- Speed/rate (-5 to 5)
- Muted status
- Selected voice (or "default")

### `/voice test` — Test Voice
Speak a test message using the current personality settings.
Run: `bash <plugin-dir>/scripts/speak.sh "test message" <volume> <rate> <voice>`

Test messages by personality:
- casual: "Hey! Voice notifications are working. Nice."
- jarvis: "Voice systems operational, sir. All is well."
- professional: "Voice notification test complete. System ready."

### `/voice setup` — Interactive Setup
Walk the user through:
1. Pick a personality (casual/jarvis/professional)
2. Test the voice
3. Adjust volume and speed
4. Confirm and save to `voice-config.json`

### `/voice mute` — Mute Voice
Set `"muted": true` in `voice-config.json`. Confirm: "Voice muted. Use /voice unmute to re-enable."

### `/voice unmute` — Unmute Voice
Set `"muted": false` in `voice-config.json`. Confirm and play a test sound.

### `/voice personality <name>` — Switch Personality
Set `"personality": "<name>"` in `voice-config.json`. Valid: casual, jarvis, professional, or any custom name in personalities.json.

### `/voice speed <number>` — Set Speech Rate
Set `"rate": <number>` in `voice-config.json`. Range: -5 (slowest) to 5 (fastest). Default: 2.

### `/voice volume <number>` — Set Volume
Set `"volume": <number>` in `voice-config.json`. Range: 0-100. Default: 100.

### `/voice voices` — List Available Voices
Run platform-specific command to list TTS voices:
- Windows: `powershell -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }"`
- macOS: `say -v '?'`
- Linux: `espeak --voices`

### `/voice custom <event> <message>` — Add Custom Message
Add a custom fallback message for a specific event type to the current personality in `personalities.json`.

## Important
- Always read the current config before making changes
- After changing settings, offer to test the new voice
- The plugin directory can be found relative to this skill file
