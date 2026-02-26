# play-audio.ps1 — Play MP3/WAV files on Windows using WPF MediaPlayer
# Usage: play-audio.ps1 <filepath> [volume 0-100]

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [int]$Volume = 100
)

Add-Type -AssemblyName presentationCore

$mp = New-Object System.Windows.Media.MediaPlayer
$mp.Open([Uri]$FilePath)
$mp.Volume = [Math]::Max(0, [Math]::Min($Volume, 100)) / 100.0
$mp.Play()

# Wait for playback to finish (max 15 seconds)
$timeout = 15
$elapsed = 0
Start-Sleep -Milliseconds 500
while ($mp.Position -lt $mp.NaturalDuration.TimeSpan -and $elapsed -lt $timeout) {
    Start-Sleep -Milliseconds 200
    $elapsed += 0.2
}
# Small buffer at the end
Start-Sleep -Milliseconds 300

$mp.Close()
