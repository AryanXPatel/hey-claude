---
name: voice
description: Configure hey-claude voice notifications — test voice, switch personality, TTS engine, mute/unmute, adjust settings
user_invocable: true
---

# Hey Claude — Voice Control

You are managing the hey-claude voice notification plugin. The user wants to configure their voice settings.

## Configuration Files

- **Voice config:** `config/voice-config.json` (in the hey-claude plugin directory)
- **Personalities:** `config/personalities.json` (in the hey-claude plugin directory)
- **TTS script:** `scripts/speak.sh` (cross-platform TTS router)

## Available Subcommands

Parse the user's arguments to determine what they want:

### `/voice` (no args) — Show Status
Read `voice-config.json` and display:
- Current personality (casual/jarvis/professional/custom)
- TTS engine (builtin or edge-tts)
- Edge TTS voice (if engine is edge-tts)
- Volume level (0-100)
- Speed/rate (-5 to 5)
- Muted status

### `/voice test` — Test Voice
Speak a test message using the current settings.
Run: `bash <plugin-dir>/scripts/speak.sh "test message" <volume> <rate> <voice>`

The speak.sh script auto-reads the engine config, so just pass the basic args.

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

**Step 2: TTS Engine**
Use AskUserQuestion to let user pick:
- Built-in (default) — uses your system's built-in TTS. Zero setup. Works offline. Basic voice quality.
- Edge TTS (Recommended) — Microsoft's neural voices. Sounds like a real person. Free, no API key. Requires internet and `pip install edge-tts`.

If user picks Edge TTS, check if it's installed:
```bash
python -c "import edge_tts" 2>/dev/null && echo "installed" || echo "not installed"
# or: python3 -c "import edge_tts" 2>/dev/null && echo "installed" || echo "not installed"
```

If not installed, offer to install it: `pip install edge-tts`

After selection, play a test with the chosen engine.

**Step 3: Voice Selection**

**If engine is edge-tts:**
List popular voices and let user pick:
```
python -c "
import edge_tts, asyncio
async def main():
    voices = await edge_tts.list_voices()
    for v in voices:
        if 'en-US' in v['ShortName']:
            print(f\"{v['ShortName']} ({v['Gender']}) — {v['FriendlyName']}\")
asyncio.run(main())
"
```

Present the best male and female voices as options using AskUserQuestion:
- en-US-ChristopherNeural (Male) — Clear, authoritative, JARVIS-like (Recommended for JARVIS)
- en-US-AndrewNeural (Male) — Smooth, professional (Recommended for Professional)
- en-US-GuyNeural (Male) — Warm, conversational (Recommended for Casual)
- en-US-BrianNeural (Male) — Casual, friendly
- en-US-RogerNeural (Male) — Deep, commanding
- en-US-AriaNeural (Female) — Natural, expressive
- en-US-JennyNeural (Female) — Professional, clear

After selection, generate and play a test using:
```bash
python <plugin-dir>/scripts/speak-edge.py "test message" "<selected-voice>" "+10%" 100
```

Let the user try multiple voices until they're happy.

**If engine is builtin:**
List available system voices:
- Windows: `powershell -NoProfile -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { Write-Host $_.VoiceInfo.Name }"`
- macOS: `say -v '?'`
- Linux: `espeak --voices`

Present as options with AskUserQuestion. Include "Default" as first option.
After selection, play a test.

**Step 4: Speed (edge-tts rate)**
If engine is edge-tts, use AskUserQuestion:
- Slow (+0%) — natural, measured
- Normal (+10%) — slightly brisk (Recommended)
- Fast (+20%) — quick notifications
- Very Fast (+30%) — rapid

If engine is builtin, use AskUserQuestion:
- Slow (Rate: 0) — deliberate, clear
- Normal (Rate: 2) — natural pace (Recommended)
- Fast (Rate: 4) — quick notifications
- Very Fast (Rate: 5) — rapid-fire

After selection, play a test at that speed.

**Step 5: Volume**
Use AskUserQuestion with options:
- Quiet (Volume: 50) — subtle
- Normal (Volume: 75) — balanced (Recommended)
- Loud (Volume: 100) — can't miss it

After selection, play a test at that volume.

**Step 6: Confirm & Save**
Show a summary of all selections:
```
Engine: edge-tts
Voice: en-US-ChristopherNeural
Personality: jarvis
Speed: +10% (normal)
Volume: 100 (loud)
```
Play a final test with all settings combined.
Ask user to confirm. If confirmed, save ALL fields to `voice-config.json`:
- personality, engine, volume, rate, muted, voice, edge_voice, edge_rate

### `/voice engine <name>` — Switch TTS Engine
Set `"engine": "<name>"` in `voice-config.json`. Valid: `builtin` or `edge-tts`.
If switching to edge-tts, check if installed. Play a test after switching.

### `/voice mute` — Mute Voice
Set `"muted": true` in `voice-config.json`. Confirm: "Voice muted. Use /voice unmute to re-enable."

### `/voice unmute` — Unmute Voice
Set `"muted": false` in `voice-config.json`. Confirm and play a test sound.

### `/voice personality <name>` — Switch Personality
Set `"personality": "<name>"` in `voice-config.json`. Valid: casual, jarvis, professional, or any custom name in personalities.json.
If the personality has a recommended `edge_voice` in personalities.json, also update `edge_voice`.
Play a test message in the new personality after switching.

### `/voice speed <value>` — Set Speech Rate
For edge-tts: set `"edge_rate": "<value>%"` (e.g., `/voice speed +20%`)
For builtin: set `"rate": <number>` (range -5 to 5)
Play a test at the new speed after setting.

### `/voice volume <number>` — Set Volume
Set `"volume": <number>` in `voice-config.json`. Range: 0-100. Default: 100.
Play a test at the new volume after setting.

### `/voice voices` — List Available Voices
If engine is edge-tts, list edge-tts voices (filtered by language if possible).
If engine is builtin, list platform system voices.
Display as a formatted table. Show which voice is currently selected.

### `/voice voice <name>` — Set Voice
If engine is edge-tts: set `"edge_voice": "<name>"` (e.g., `en-US-ChristopherNeural`)
If engine is builtin: set `"voice": "<name>"` (system voice name)
Play a test with the new voice after setting.

### `/voice custom <event> <message>` — Add Custom Message
Add a custom fallback message for a specific event type to the current personality in `personalities.json`.
Valid events: permission_prompt, idle_prompt, elicitation_dialog

### `/voice reset` — Reset to Defaults
Reset `voice-config.json` to defaults: casual personality, builtin engine, volume 100, rate 2, unmuted, no specific voice.

## Important
- Always read the current config before making changes
- After EVERY setting change, play a test so the user hears the difference immediately
- The plugin directory can be found relative to this skill file
- Use speak.sh for all TTS: `bash <plugin-dir>/scripts/speak.sh "message" <volume> <rate> <voice>`
- speak.sh auto-reads the engine config, so it routes to edge-tts or builtin automatically
- For edge-tts testing directly: `python <plugin-dir>/scripts/speak-edge.py "message" "voice-id" "+10%" 100`
