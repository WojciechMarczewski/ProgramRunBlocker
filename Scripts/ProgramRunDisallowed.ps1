param ( 
    [string]$FolderPath
)

# Function to convert date to FILETIME
function ConvertTo-FileTime {
    param ([datetime]$DateTime)
    return [BitConverter]::ToUInt64([BitConverter]::GetBytes((New-TimeSpan -Start "1601-01-01" -End $DateTime).Ticks), 0)
}

# Function to change or add a path rule to Disallowed
function Set-SoftwareRestrictionPathRuleDisallowed {
    param (
        [string]$Path
    )

    # Ensure you are running PowerShell as Administrator
    $ErrorActionPreference = "Stop"

    try {
        # Path to Software Restriction Policies key
        $srpPath = "HKLM:\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers"

        # Create folder for Disallowed if it doesn't exist
        if (!(Test-Path "$srpPath\0\Paths")) {
            New-Item -Path "$srpPath\0\Paths" -Force | Out-Null
        }

        $ruleFound = $false
        $description = "Rule created by script"
        $lastModified = ConvertTo-FileTime (Get-Date)

        # Move rule from Allowed (262144) to Disallowed (0)
        $rules = Get-ChildItem -Path "$srpPath\262144\Paths"
        foreach ($rule in $rules) {
            $rulePath = Get-ItemProperty -Path $rule.PSPath
            if ($rulePath.ItemData -eq $Path) {
                $newRuleKey = "$srpPath\0\Paths\$($rule.PSChildName)"
                Copy-Item -Path $rule.PSPath -Destination $newRuleKey -Recurse -Force
                Set-ItemProperty -Path $newRuleKey -Name "Description" -Value $description
                Set-ItemProperty -Path $newRuleKey -Name "LastModified" -Type QWORD -Value $lastModified
                Remove-Item -Path $rule.PSPath -Force
                Write-Output "$(Get-Date): Rule for $Path moved from 262144 to 0."
                Write-Output "New rule key created at: $newRuleKey"
                $ruleFound = $true
                break
            }
        }

        # Check Disallowed folder if rule not found
        if (-not $ruleFound) {
            $rules = Get-ChildItem -Path "$srpPath\0\Paths"
            foreach ($rule in $rules) {
                $rulePath = Get-ItemProperty -Path $rule.PSPath
                if ($rulePath.ItemData -eq $Path) {
                    Write-Output "$(Get-Date): Rule for $Path already exists in path $srpPath\0\Paths."
                    $ruleFound = $true
                    break
                }
            }
        }

        # Add new rule if no rule found
        if (-not $ruleFound) {
            $newRuleKey = "$srpPath\0\Paths\$([guid]::NewGuid().ToString('B'))"
            New-Item -Path $newRuleKey -Force | Out-Null
            Set-ItemProperty -Path $newRuleKey -Name "ItemData" -Value $Path
            Set-ItemProperty -Path $newRuleKey -Name "SaferFlags" -Value 0x0
            Set-ItemProperty -Path $newRuleKey -Name "Description" -Value $description
            Set-ItemProperty -Path $newRuleKey -Name "LastModified" -Type QWORD -Value $lastModified
            Write-Output "$(Get-Date): New rule created for $Path in path $srpPath\0\Paths."
        }
    } catch {
        Write-Output "$(Get-Date): An error occurred: $_"
    }
}

# Execute the function for our path
Set-SoftwareRestrictionPathRuleDisallowed -Path $FolderPath
