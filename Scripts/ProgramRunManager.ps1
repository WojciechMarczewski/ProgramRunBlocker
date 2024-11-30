# Parameters
param ( 
    [string]$SelectedFolder, 
    [string]$StartTime = "20:00:00",
    [string]$EndTime = "01:00:00",
    [string]$TaskName = "ProgramRunBlockerTask"
)

# Check if an existing task exists and retrieve its values
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($existingTask) {
    $arguments = $existingTask.Actions[0].Arguments -split ' '
    if ($arguments.Length -ge 5) { $SelectedFolder = $arguments[4] }
    if ($arguments.Length -ge 6) { $StartTime = $arguments[5] }
    if ($arguments.Length -ge 7) { $EndTime = $arguments[6] }
}

# Add '*' to the folder path and ensure the path is not enclosed in quotes
$SelectedFolder = "$SelectedFolder\*" -replace '"', '' 

# Paths to Allowed and Disallowed scripts
$allowedScript = ".\ProgramRunAllowed.ps1"
$disallowedScript = ".\ProgramRunDisallowed.ps1"
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the current time
$currentTime = Get-Date
$currentHour = $currentTime.Hour
$currentMinute = $currentTime.Minute
$currentSecond = $currentTime.Second
$currentHourMinuteSecond = "{0:D2}:{1:D2}:{2:D2}" -f $currentHour, $currentMinute, $currentSecond

cd $scriptDirectory

# Check if the current time is between StartTime and EndTime
if (($currentHourMinuteSecond -ge $StartTime) -or ($currentHourMinuteSecond -lt $EndTime)) {
    Write-Output "The current time is between $StartTime and $EndTime. Running Disallowed script."
    & $disallowedScript $SelectedFolder
} else {
    Write-Output "The current time is not between $StartTime and $EndTime. Running Allowed script."
    & $allowedScript $SelectedFolder
}
gpupdate /force

# Exit PowerShell
exit
