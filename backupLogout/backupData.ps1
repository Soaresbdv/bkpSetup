param(
    [string]$username = $env:USERNAME
)

# Função para resolver variáveis de ambiente dentro de strings (ex: $env:USERNAME)
function Resolve-PathWithVars {
    param ([string]$Path)
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

# Caminho absoluto para o config.json (um nível acima)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configPath = Join-Path (Split-Path $scriptDir -Parent) "config.json"
$config = (Get-Content $configPath -Raw | ConvertFrom-Json).backupSetup

# Resolve todos os caminhos com variáveis de ambiente
$sourcePath = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars ($config.networkPath + "\$username")
$backupSetupPath = Resolve-PathWithVars $config.backupSetupPath

# Cria diretório de origem local se não existir
if (!(Test-Path -Path $sourcePath)) {
    New-Item -ItemType Directory -Path $sourcePath -Force | Out-Null
    Write-Host "Source directory created at $sourcePath"
}

# Cria diretório de destino se não existir
if (!(Test-Path -Path $networkPath)) {
    New-Item -ItemType Directory -Path $networkPath -Force | Out-Null
    Write-Host "Network directory created at $networkPath"
}

# Limpa backup anterior, se houver
if (Test-Path -Path $backupSetupPath) {
    try {
        Remove-Item -Path "$backupSetupPath\*" -Recurse -Force
        Write-Host "Old backup deleted successfully from $backupSetupPath"
    } catch {
        Write-Host "Error during deletion: $_"
    }
}

# Copia conteúdo do sourcePath para networkPath
try {
    Copy-Item -Path $sourcePath -Destination $networkPath -Recurse -Force
    Write-Host "Backup completed successfully from $sourcePath to $networkPath"
} catch {
    Write-Host "Error during backup: $_"
}
