param(
    [Parameter(Mandatory=$true)]
    [string]$Message,

    [int]$Volume = 100,

    [int]$Rate = 2,

    [string]$Voice = ""
)

Add-Type -AssemblyName System.Speech

$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Volume = $Volume
$synth.Rate = $Rate

if ($Voice -ne "" -and $Voice -ne "null") {
    try {
        $synth.SelectVoice($Voice)
    } catch {
        # Fallback to default voice if specified voice not found
    }
}

$synth.Speak($Message)
$synth.Dispose()
