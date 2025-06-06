# restoreChrome.ps1

# Carrega config.json
$config = (Get-Content (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\\config.json") -Raw | ConvertFrom-Json).chrome

# Resolve variáveis com ambiente
function Resolve-PathWithVars {
    param ([string]$Path)
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

# == RESTORE CHROME ==
$chromeConfig = $config
$sourcePath = Join-Path (Resolve-PathWithVars $chromeConfig.networkPath) (Join-Path $env:USERNAME "chrome")
$destinationPath = Resolve-PathWithVars $chromeConfig.sourcePath
$ignoredFolders = $chromeConfig.ignoredFolders

Write-Host "Restaurando dados do Chrome de $sourcePath para $destinationPath" -ForegroundColor Cyan

function ShouldIgnoreRelativePath {
    param (
        [string]$FullPath,
        [string]$BasePath,
        [string[]]$IgnoreList
    )
    $relativePath = $FullPath.Substring($BasePath.Length).TrimStart('\\')
    foreach ($ignore in $IgnoreList) {
        if ($relativePath -replace '/', '\\' -like "*$ignore*") {
            return $true
        }
    }
    return $false
}

if (-not (Test-Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

$failedCopies = @()
$items = Get-ChildItem -Path $sourcePath -Recurse -Force -ErrorAction SilentlyContinue
foreach ($item in $items) {
    if (ShouldIgnoreRelativePath -FullPath $item.FullName -BasePath $sourcePath -IgnoreList $ignoredFolders) {
        Write-Host "Ignorando: $($item.FullName)" -ForegroundColor Yellow
        continue
    }

    $target = $item.FullName.Replace($sourcePath, $destinationPath)
    try {
        if ($item.PSIsContainer) {
            if (-not (Test-Path $target)) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            }
        } else {
            $parent = Split-Path $target -Parent
            if (-not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            Copy-Item -Path $item.FullName -Destination $target -Force
        }
    } catch {
        $failedCopies += $item.FullName
    }
}

if ($failedCopies.Count -gt 0) {
    Write-Host "`nFalha ao restaurar os seguintes arquivos do Chrome:" -ForegroundColor Yellow
    $failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "`nRestauro do Chrome concluído com sucesso!" -ForegroundColor Green
}
