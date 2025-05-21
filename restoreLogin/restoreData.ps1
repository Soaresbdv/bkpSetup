# Script: BackupSetup.ps1

# Define paths
$UserName = $env:USERNAME
$DesktopPath = "C:\Users\$UserName\Desktop"
$LocalBackupPath = "$DesktopPath\BackupSetup"
$NetworkBackupPath = "\\192.168.15.204\pcs\fileSystem\userBackup\$UserName\BackupSetup"

# Function to close only the BackupSetup folder if it's open in Explorer
function Close-ExplorerWindow {
    $explorerProcesses = Get-Process -Name explorer -ErrorAction SilentlyContinue

    foreach ($proc in $explorerProcesses) {
        try {
            $windows = New-Object -ComObject Shell.Application
            foreach ($window in $windows.Windows()) {
                if ($window.LocationURL -like "*BackupSetup*") {
                    $window.Quit()
                }
            }
        } catch {
            Write-Host "Failed to close specific folder window: $_"
        }
    }
}

# Check if BackupSetup folder exists on Desktop
if (Test-Path $LocalBackupPath) {
    # Close only the BackupSetup folder if it is open
    Close-ExplorerWindow

    # Remove the local BackupSetup folder
    Remove-Item -Recurse -Force $LocalBackupPath
    Write-Host "Local BackupSetup folder deleted successfully."
}

# Check if the folder exists on the network path
if (Test-Path $NetworkBackupPath) {
    # Copy from network path to Desktop
    Copy-Item -Recurse -Force $NetworkBackupPath $DesktopPath
    Write-Host "BackupSetup folder copied from network to Desktop successfully."
} else {
    # If network folder doesn't exist, create an empty BackupSetup folder on Desktop
    New-Item -ItemType Directory -Path $LocalBackupPath
    Write-Host "Network folder not found. Created an empty BackupSetup folder on Desktop."
}
