# backupMicrosip.ps1

# Carrega o config.json e converte para objeto
$config = (Get-Content (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\\config.json") -Raw | ConvertFrom-Json).microsip

# Resolve variáveis de ambiente no caminho
function Resolve-PathWithVars {
    param ([string]$Path)
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

$sourcePath = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars $config.networkPath
$username = $env:USERNAME

# Aqui garantimos que a pasta de destino seja '...\userBackup\<usuario>\microsip'
$userBackupPath = Join-Path $networkPath $username
$microsipBackupPath = Join-Path $userBackupPath "microsip"

$failedCopies = @()

# Cria estrutura de destino
if (!(Test-Path $microsipBackupPath)) {
    New-Item -ItemType Directory -Path $microsipBackupPath | Out-Null
}

# Função recursiva para copiar arquivos e pastas
function Copy-Folder {
    param (
        [string]$Source,
        [string]$Destination
    )

    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination | Out-Null
    }

    $items = Get-ChildItem -Path $Source -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        $destItemPath = Join-Path $Destination $item.Name
        try {
            if ($item.PSIsContainer) {
                Copy-Folder -Source $item.FullName -Destination $destItemPath
            } else {
                Copy-Item -Path $item.FullName -Destination $destItemPath -Force
            }
        } catch {
            $script:failedCopies += $item.FullName
        }
    }
}

# Executa o backup
Copy-Folder -Source $sourcePath -Destination $microsipBackupPath

# Relatório final
if ($failedCopies.Count -gt 0) {
    Write-Host "`nArquivos não copiados:" -ForegroundColor Yellow
    $failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Backup do MicroSIP concluído com sucesso!" -ForegroundColor Green
}
