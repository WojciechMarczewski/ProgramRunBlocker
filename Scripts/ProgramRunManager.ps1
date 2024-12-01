# Parameters
param ( 
    [string]$SelectedFolder, 
    [string]$StartTime = "20:00:00",
    [string]$EndTime = "23:59:59",
    [string]$TaskName = "ProgramRunBlockerTask"
)


Start-Transcript -Path ".\TaskBlockerLog.txt"

# Function to split arguments considering quotes
function Split-Arguments {
    param (
        [string]$arguments
    )

    # Regular expression to split arguments considering quotes
    $regex = '(?<=^| )(\"[^\"]+\"|\S+)(?=$| )'
    return [regex]::matches($arguments, $regex) | ForEach-Object { $_.Value.Trim() }
}

# Check if an existing task exists and retrieve its values
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($existingTask) {
    $arguments = Split-Arguments -arguments $existingTask.Actions[0].Arguments
    if ($arguments.Length -ge 5) { $SelectedFolder = $arguments[4].Trim('"') }
    if ($arguments.Length -ge 6) { $StartTime = $arguments[5] }
    if ($arguments.Length -ge 7) { $EndTime = $arguments[6] }
}

# Add '*' to the folder path
$SelectedFolder = "$SelectedFolder\*"

# Paths to Allowed and Disallowed scripts
$allowedScript = ".\ProgramRunAllowed.ps1"
$disallowedScript = ".\ProgramRunDisallowed.ps1"
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the current time
$currentTime = Get-Date
$currentHourMinuteSecond = "{0:D2}:{1:D2}:{2:D2}" -f $currentTime.Hour, $currentTime.Minute, $currentTime.Second



# Parse the start and end times
$startTimeSpan = [TimeSpan]::Zero
$endTimeSpan = [TimeSpan]::Zero

$StartTime = $StartTime.Trim('"')
$EndTime = $EndTime.Trim('"')

if (![TimeSpan]::TryParseExact($StartTime, "c", $null, [Globalization.DateTimeStyles]::None, [ref]$startTimeSpan)) {
    Write-Output "Failed to parse StartTime. Please ensure it is in the format HH:mm:ss. Your Input: $StartTime"
    Stop-Transcript
    exit
}

if (![TimeSpan]::TryParseExact($EndTime, "c", $null, [Globalization.DateTimeStyles]::None, [ref]$endTimeSpan)) {
    Write-Output "Failed to parse EndTime. Please ensure it is in the format HH:mm:ss. Your Input: $EndTime"
    Stop-Transcript
    exit
}

cd $scriptDirectory

# Check if the current time is between StartTime and EndTime
if (($currentTime.TimeOfDay -ge $startTimeSpan) -and ($currentTime.TimeOfDay -lt $endTimeSpan)) {
    Write-Output "The current time is between $StartTime and $EndTime. Running Allowed script." 
    . $allowedScript $SelectedFolder
} else {
    Write-Output "The current time is not between $StartTime and $EndTime. Running Disallowed script."
    . $disallowedScript $SelectedFolder
}
gpupdate /force

Stop-Transcript
# Exit PowerShell
exit
