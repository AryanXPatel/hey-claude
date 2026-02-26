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

### `/voice setup` — Interactive Setup Wizard

Walk the user through a multi-step setup using AskUserQuestion for each step.
After EACH step, play a test with the current selections so the user hears the difference.

**Step 1: Personality**
Use AskUserQuestion to let user pick:
- Casual Buddy (default) — friendly, colleague-like
- JARVIS — formal AI assistant, Iron Man style
- Professional — clean and informative

After selection, play a test message in that personality style.

**Step 2: Voice**
First, list available system voices by running:
- Windows: `powershell -NoProfile -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { Write-Host $_.VoiceInfo.Name }"`
- macOS: `say -v '?'`
- Linux: `espeak --voices`

Then use AskUserQuestion to present available voices as options. Include "Default" as the first option.
After selection, play a test with the chosen voice so the user can hear it.
If the user doesn't like it, let them try another voice.

**Step 3: Speed**
Use AskUserQuestion with options:
- Slow (Rate: 0) — deliberate, clear
- Normal (Rate: 2) — natural pace (Recommended)
- Fast (Rate: 4) — quick notifications
- Very Fast (Rate: 5) — rapid-fire

After selection, play a test at that speed.

**Step 4: Volume**
Use AskUserQuestion with options:
- Quiet (Volume: 50) — subtle
- Normal (Volume: 75) — balanced (Recommended)
- Loud (Volume: 100) — can't miss it

After selection, play a test at that volume.

**Step 5: Confirm & Save**
Show a summary of all selections:
```
Personality: jarvis
Voice: Microsoft David
Speed: 2 (normal)
Volume: 100 (loud)
```
Play a final test with all settings combined.
Ask user to confirm. If confirmed, save to `voice-config.json`.

### `/voice mute` — Mute Voice
Set `"muted": true` in `voice-config.json`. Confirm: "Voice muted. Use /voice unmute to re-enable."

### `/voice unmute` — Unmute Voice
Set `"muted": false` in `voice-config.json`. Confirm and play a test sound.

### `/voice personality <name>` — Switch Personality
Set `"personality": "<name>"` in `voice-config.json`. Valid: casual, jarvis, professional, or any custom name in personalities.json.
Play a test message in the new personality after switching.

### `/voice speed <number>` — Set Speech Rate
Set `"rate": <number>` in `voice-config.json`. Range: -5 (slowest) to 5 (fastest). Default: 2.
Play a test at the new speed after setting.

### `/voice volume <number>` — Set Volume
Set `"volume": <number>` in `voice-config.json`. Range: 0-100. Default: 100.
Play a test at the new volume after setting.

### `/voice voices` — List Available Voices
Run platform-specific command to list TTS voices:
- Windows: `powershell -NoProfile -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { Write-Host $_.VoiceInfo.Name }"`
- macOS: `say -v '?'`
- Linux: `espeak --voices`

Display as a formatted list. Show which voice is currently selected.

### `/voice voice <name>` — Set Voice
Set `"voice": "<name>"` in `voice-config.json`. The name must match an installed system voice.
Play a test with the new voice after setting.

### `/voice custom <event> <message>` — Add Custom Message
Add a custom fallback message for a specific event type to the current personality in `personalities.json`.
Valid events: permission_prompt, idle_prompt, elicitation_dialog

### `/voice reset` — Reset to Defaults
Reset `voice-config.json` to defaults (casual personality, volume 100, rate 2, no specific voice, unmuted).

## Important
- Always read the current config before making changes
- After EVERY setting change, play a test so the user hears the difference immediately
- The plugin directory can be found relative to this skill file
- Use the speak.sh script for all TTS: `bash <plugin-dir>/scripts/speak.sh "message" <volume> <rate> <voice>`
