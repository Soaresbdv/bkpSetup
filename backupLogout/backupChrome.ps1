# Está tudo liso!

# Carrega o config.json e converte para objeto
$config = (Get-Content (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\config.json") -Raw | ConvertFrom-Json).chrome

# Resolve variáveis de ambiente no caminho
function Resolve-PathWithVars {
    param ([string]$Path)
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

$sourceBase = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars $config.networkPath
$ignoredFolders = $config.ignoredFolders
$username = $env:USERNAME
$userBackupPath = Join-Path $networkPath $username
$chromeBackupPath = Join-Path $userBackupPath "chrome"
$failedCopies = @()

# Função para calcular tamanho de pasta
function Get-FolderSize {
    param ([string]$Path)
    try {
        return (Get-ChildItem -Path $Path -Recurse -Force | Measure-Object -Property Length -Sum).Sum
    } catch {
        return 0
    }
}

# Identifica o maior perfil
$profiles = Get-ChildItem -Path $sourceBase -Directory | Where-Object {
    $_.Name -match "^Default$|^Profile \d+$"
}

$largestProfile = $null
$largestSize = 0

foreach ($profile in $profiles) {
    $size = Get-FolderSize -Path $profile.FullName
    if ($size -gt $largestSize) {
        $largestSize = $size
        $largestProfile = $profile
    }
}

if (-not $largestProfile) {
    Write-Host "Nenhum perfil encontrado." -ForegroundColor Red
    exit
}

Write-Host "Perfil selecionado: $($largestProfile.Name) com $([math]::Round($largestSize / 1MB, 2)) MB" -ForegroundColor Cyan
$sourcePath = $largestProfile.FullName

# Cria estrutura de destino
if (!(Test-Path $userBackupPath)) {
    New-Item -ItemType Directory -Path $userBackupPath | Out-Null
}
if (Test-Path $chromeBackupPath) {
    Remove-Item -Recurse -Force $chromeBackupPath
}
New-Item -ItemType Directory -Path $chromeBackupPath | Out-Null

# Nova função para verificar se o caminho deve ser ignorado (subpasta inclusa)
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

# Função recursiva para copiar ignorando pastas por caminho
function Copy-Folder {
    param (
        [string]$Source,
        [string]$Destination,
        [string[]]$Ignore
    )

    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination | Out-Null
    }

    $items = Get-ChildItem -Path $Source -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if (ShouldIgnoreRelativePath -FullPath $item.FullName -BasePath $sourcePath -Ignore $Ignore) {
            Write-Host "Ignorando: $($item.FullName)" -ForegroundColor Yellow
            continue
        }

        $destItemPath = Join-Path $Destination $item.Name
        try {
            if ($item.PSIsContainer) {
                Copy-Folder -Source $item.FullName -Destination $destItemPath -Ignore $Ignore
            } else {
                Copy-Item -Path $item.FullName -Destination $destItemPath -Force
            }
        } catch {
            $script:failedCopies += $item.FullName
        }
    }
}

# Executa o backup
Copy-Folder -Source $sourcePath -Destination $chromeBackupPath -Ignore $ignoredFolders

# Relatório final
if ($failedCopies.Count -gt 0) {
    Write-Host "`nArquivos não copiados:" -ForegroundColor Yellow
    $failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Backup do Chrome concluído com sucesso!" -ForegroundColor Green
}
