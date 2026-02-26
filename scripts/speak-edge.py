"""
speak-edge.py — Edge TTS speech engine for hey-claude
Usage: python speak-edge.py "message" [voice] [rate] [volume]

Generates speech using Microsoft Edge's free neural TTS and plays it.
Requires: pip install edge-tts
"""

import sys
import os
import asyncio
import tempfile
import subprocess
import platform

async def speak(message, voice="en-US-ChristopherNeural", rate="+10%", volume=100):
    try:
        import edge_tts
    except ImportError:
        print("hey-claude: edge-tts not installed. Run: pip install edge-tts", file=sys.stderr)
        sys.exit(1)

    # Generate MP3
    output = os.path.join(tempfile.gettempdir(), "hey_claude_edge.mp3")
    communicate = edge_tts.Communicate(message, voice, rate=rate)
    await communicate.save(output)

    # Play based on platform
    system = platform.system()

    if system == "Windows" or "MINGW" in os.environ.get("MSYSTEM", ""):
        # Windows — use PowerShell WPF MediaPlayer
        script_dir = os.path.dirname(os.path.abspath(__file__))
        play_script = os.path.join(script_dir, "play-audio.ps1")
        subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-File", play_script, output, str(volume)],
            capture_output=True, timeout=15
        )
    elif system == "Darwin":
        # macOS — afplay supports MP3 natively
        vol = max(0, min(volume, 100)) / 100.0
        subprocess.run(["afplay", "-v", str(vol), output], capture_output=True, timeout=15)
    else:
        # Linux — try mpv, then ffplay, then convert to wav and aplay
        if _cmd_exists("mpv"):
            subprocess.run(["mpv", "--no-video", f"--volume={volume}", output], capture_output=True, timeout=15)
        elif _cmd_exists("ffplay"):
            subprocess.run(["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", output], capture_output=True, timeout=15)
        else:
            print("hey-claude: No MP3 player found. Install mpv: sudo apt install mpv", file=sys.stderr)

def _cmd_exists(cmd):
    import shutil
    return shutil.which(cmd) is not None

if __name__ == "__main__":
    message = sys.argv[1] if len(sys.argv) > 1 else ""
    voice = sys.argv[2] if len(sys.argv) > 2 else "en-US-ChristopherNeural"
    rate = sys.argv[3] if len(sys.argv) > 3 else "+10%"
    volume = int(sys.argv[4]) if len(sys.argv) > 4 else 100

    if not message:
        sys.exit(0)

    asyncio.run(speak(message, voice, rate, volume))
