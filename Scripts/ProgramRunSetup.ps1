# Function to display folder picker dialog
function Show-FolderPicker {
    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder where files will be blocked"
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        return $null
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
$time2 = Show-InputBox -message "Enter end time (HH:MM:SS). This is the time when the script will stop blocking access to files in the selected folder." -default "01:00:01"

$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -Daily -At $time1
$trigger3 = New-ScheduledTaskTrigger -Daily -At $time2

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File `"$scriptPath`" $selectedFolder `"$time1`" `"$time2`" `"$taskName`""

# -----------------------------------------------

# Remove existing task (if any)
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create new task
Register-ScheduledTask -TaskName $taskName -Trigger $trigger1, $trigger2, $trigger3 -Action $action -RunLevel Highest -User "SYSTEM"

# Show confirmation dialog
Show-MessageBox -message "The task '$taskName' has been set up successfully. You can check the results in Task Scheduler. The task will run at startups and every day at $time1 and $time2 to enforce the policy."

exit
