# Function to display folder picker dialog
function Show-FolderPicker {
    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder where files will be blocked"
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        exit
    }
}

# Function to display InputBox dialog
function Show-InputBox {
    param (
        [string]$message,
        [string]$default
    )

    Add-Type -AssemblyName Microsoft.VisualBasic
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($message, "Enter value", $default)
    if($input -eq "") {
        exit
    }
    return $input
}

# Function to display message box dialog
function Show-MessageBox {
    param (
        [string]$message
    )

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($message, "Confirmation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Variables
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path -Path $scriptDirectory -ChildPath "ProgramRunManager.ps1"
$selectedFolder = Show-FolderPicker

# Prompt the user for task name with brief explanation
$taskName = Show-InputBox -message "Enter the task name. This task will manage blocking and allowing files in the selected folder based on scheduled times." -default "ProgramRunBlockerTask"

# Prompt the user for start and end times
$time1 = Show-InputBox -message "Enter start time (HH:MM:SS). This is the time when the script will start blocking access to files in the selected folder." -default "20:00:01"
$time2 = Show-InputBox -message "Enter end time (HH:MM:SS). This is the time when the script will stop blocking access to files in the selected folder." -default "23:59:59"

$trigger1 = New-ScheduledTaskTrigger -AtLogOn 
$trigger2 = New-ScheduledTaskTrigger -Daily -At $time1
$trigger3 = New-ScheduledTaskTrigger -Daily -At $time2

$triggers = @($trigger1, $trigger2, $trigger3)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File `"$scriptPath`" `"$selectedFolder`" `"$time1`" `"$time2`" `"$taskName`""
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# -----------------------------------------------

# Remove existing task (if any)
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
try{
# Register the new task 
Register-ScheduledTask -TaskName $taskName -Trigger $triggers -Action $action -Principal $principal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) 

# Start new Task
Start-ScheduledTask -TaskName $taskName 
# Show confirmation dialog
Show-MessageBox -message "The task '$taskName' has been set up successfully.`n You can check the results in Task Scheduler.`n The task will run at startups and every day at $time1 and $time2 to enforce the policy."}
catch{
# Capture the error message 
$errorMessage = $_.Exception.Message
# Show error message 
Show-MessageBox -message "There was an error setting up the task '$taskName'. Error: `n$errorMessage" -title "Task Creation Failed"
}
exit
