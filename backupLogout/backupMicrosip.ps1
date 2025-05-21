# Load the config.json file and convert it to a PowerShell object (specifically for MicroSIP)
$config = (Get-Content ".\config.json" -Raw | ConvertFrom-Json).microsip

# Function to resolve environment variables in paths
function Resolve-PathWithVars {
    param (
        [string]$Path
    )

    # Replace environment variables like $env:USERNAME, %USERNAME%, etc.
    $Path = $ExecutionContext.InvokeCommand.ExpandString($Path)
    return $Path
}

# Load configuration variables from config.json and resolve paths
$sourcePath = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars $config.networkPath
$ignoredFolders = $config.ignoredFolders

# Retrieve the current user's name
$username = $env:USERNAME

# Define the user's backup directory path on the network
$userBackupPath = Join-Path $networkPath $username

# Define the MicroSIP backup directory path
$microSIPBackupPath = Join-Path $userBackupPath "MicroSIP"

# Variable to store files that failed to copy
$failedCopies = @()

# Create the user backup directory if it doesn't exist
if (!(Test-Path $userBackupPath)) {
    New-Item -ItemType Directory -Path $userBackupPath | Out-Null
}

# Remove the existing "MicroSIP" folder if it exists
if (Test-Path $microSIPBackupPath) {
    Remove-Item -Recurse -Force $microSIPBackupPath
}

# Create a new "MicroSIP" folder
New-Item -ItemType Directory -Path $microSIPBackupPath | Out-Null

# Recursive function to copy folders while ignoring specified ones
function Copy-Folder {
    param (
        [string]$Source,
        [string]$Destination,
        [string[]]$Ignore
    )

    # Create the destination directory if it doesn't exist
    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination | Out-Null
    }

    # Filter files and folders to be ignored before copying
    $items = Get-ChildItem -Path $Source -Force -ErrorAction Stop

    foreach ($item in $items) {
        $itemName = $item.Name

        if ($item.PSIsContainer) {
            if ($Ignore -contains $itemName) {
                Write-Host "Ignoring folder: $itemName" -ForegroundColor Yellow
                continue
            }

            # Recursively copy valid folders
            $subDestination = Join-Path $Destination $itemName
            Copy-Folder -Source $item.FullName -Destination $subDestination -Ignore $Ignore
        }
        else {
            try {
                $destinationPath = Join-Path $Destination $itemName
                Copy-Item -Path $item.FullName -Destination $destinationPath -Force -ErrorAction Stop
            }
            catch {
                $failedCopies += $item.FullName
            }
        }
    }
}

# Execute the copy function
Copy-Folder -Source $sourcePath -Destination $microSIPBackupPath -Ignore $ignoredFolders

# Display files that failed to copy, if any
if ($failedCopies.Count -gt 0) {
    Write-Host "`nFiles not copied:" -ForegroundColor Yellow
    Write-Host "List:" -ForegroundColor Yellow
    $failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Copy completed successfully!" -ForegroundColor Green
}
