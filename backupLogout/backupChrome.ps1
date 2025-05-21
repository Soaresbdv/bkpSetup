# Backup Chrome - Atualizado
# Carrega config
$config = (Get-Content ".\config.json" -Raw | ConvertFrom-Json).chrome

function Resolve-PathWithVars {
    param ([string]$Path)
    $Path = $ExecutionContext.InvokeCommand.ExpandString($Path)
    return $Path
}

$sourcePath = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars $config.networkPath
$ignoredFolders = $config.ignoredFolders

$username = $env:USERNAME
$userBackupPath = Join-Path $networkPath $username
$chromeBackupPath = Join-Path $userBackupPath "chrome"

$global:failedCopies = @()

if (!(Test-Path $userBackupPath)) { New-Item -ItemType Directory -Path $userBackupPath | Out-Null }
if (Test-Path $chromeBackupPath) { Remove-Item -Recurse -Force $chromeBackupPath }
New-Item -ItemType Directory -Path $chromeBackupPath | Out-Null

function Copy-Folder {
    param ([string]$Source, [string]$Destination, [string[]]$Ignore)

    if (!(Test-Path $Destination)) { New-Item -ItemType Directory -Path $Destination | Out-Null }

    $items = Get-ChildItem -Path $Source -Force -ErrorAction Stop
    foreach ($item in $items) {
        $relativePath = ($item.FullName -replace [regex]::Escape($Source), "").TrimStart("\")
        $normalizedPath = $relativePath -replace "\", "/"

        if ($Ignore -contains $normalizedPath -or $Ignore -contains $item.Name) {
            Write-Host "Ignoring folder: $normalizedPath" -ForegroundColor Yellow
            continue
        }

        if ($item.PSIsContainer) {
            $subDestination = Join-Path $Destination $item.Name
            Copy-Folder -Source $item.FullName -Destination $subDestination -Ignore $Ignore
        } else {
            try {
                $destinationPath = Join-Path $Destination $item.Name
                Copy-Item -Path $item.FullName -Destination $destinationPath -Force -ErrorAction Stop
            } catch {
                $global:failedCopies += $item.FullName
            }
        }
    }
}

Copy-Folder -Source $sourcePath -Destination $chromeBackupPath -Ignore $ignoredFolders

if ($global:failedCopies.Count -gt 0) {
    Write-Host "`nFiles not copied:" -ForegroundColor Yellow
    $global:failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Copy completed successfully!" -ForegroundColor Green
}