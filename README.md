# PowerShell Scripts for Blocking `.exe` Files During Specific Hours

This repository contains PowerShell scripts designed to restrict the execution of `.exe` files in a specified folder during certain hours. These scripts leverage the Windows Registry and the Software Restriction Policies mechanism. They are intended to be used with the Windows Task Scheduler for scheduled activation.

## Features

- **Folder Selection**: Users can specify the folder where `.exe` file restrictions will be applied.
- **Time-Based Restrictions**: Users define a time range (e.g., 9 AM to 5 PM) during which `.exe` files in the folder can be executed.
- **Custom Task Naming**: Users can name each restriction task for easy identification in the Task Scheduler.
- **Automation**: Scripts handle the creation and removal of necessary registry entries for enforcing Software Restriction Policies at system startup and specified hours.

## Prerequisites

- **Windows Operating System**: The scripts are designed to run on Windows.
- **Administrative Privileges** (IMPORTANT!): Since the scripts modify the Windows Registry, they require administrator permissions.
- **Task Scheduler**: The scripts are designed to be executed as scheduled tasks.

## Installation and Setup

1. **Download the Package**:
[ProgramRunBlocker.zip](https://github.com/user-attachments/files/17992543/ProgramRunBlocker.zip)


2. **Extract Files**:
   - Extract the downloaded `.zip` file into a directory of your choice.

3. **Run the Setup**:
   - Locate and run the `RunSetup.bat` file. This will execute the `ProgramRunSetup.ps1` script with administrative privileges.
   - Follow the on-screen instructions to:
     - Select a folder to block `.exe` files.
     - Specify the start and end times during which the user will have access to the application.
     - Provide a name for the scheduled task.

4. **Task Scheduler**:
   - The setup creates a scheduled task that manages the rules for allowed and disallowed programs at specified times.

## How It Works
- **Registry Modification**:

The script modifies the HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers key in the Windows Registry.
It creates or moves registry entries to define the software restriction policies for the specified folder.
- **Time-Based Logic**:

The task scheduler triggers the script to enable or disable restrictions at the configured times.
- **Task Automation**:

A task is created in the Windows Task Scheduler to automatically enforce the restriction logic.

## Example Scenarios

- **Steam Blocking and Game Restrictions**: Prevent access to Steam or other gaming applications during specified hours.
- **Control Development Tools**: Limit access to specific tools or applications to enforce focus during specific periods.
- **Productivity Management**: Restrict usage of distracting apps during focus hours.

## Limitations
The script does not validate the contents of the folder. Ensure you specify the correct directory.
Users must have administrative privileges to execute the script and register tasks.
The task relies on Windows' built-in Software Restriction Policies and may not be compatible with older versions of Windows. 
Scripts do not stop currently running software.

## Script Details

### `ProgramRunManager.ps1`
- **Purpose**: Manages switching between allowed and disallowed states for `.exe` files in the specified folder.
- **Logic**:
  - If the current time is within the blocking period, it runs `ProgramRunDisallowed.ps1`.
  - Otherwise, it runs `ProgramRunAllowed.ps1`.

### `ProgramRunAllowed.ps1`
- **Purpose**: Moves program execution rules to the "Allowed" state in the Windows Software Restriction Policies.
- **Key Functionality**:
  - Modifies registry keys to mark `.exe` files in the specified folder as allowed.

### `ProgramRunDisallowed.ps1`
- **Purpose**: Moves program execution rules to the "Disallowed" state in the Windows Software Restriction Policies.
- **Key Functionality**:
  - Modifies registry keys to block `.exe` files in the specified folder.

### `ProgramRunSetup.ps1`
- **Purpose**: Simplifies setup by guiding the user through folder selection, time specification, and task creation.
- **Interactive Features**:
  - Folder picker.
  - Input dialogs for time and task name.
  - Creates and registers tasks in Task Scheduler.

### `RunSetup.bat`
- **Purpose**: Launches the `ProgramRunSetup.ps1` script with administrative privileges.
  
## Contribution
Feel free to open issues or submit pull requests to improve the scripts.
