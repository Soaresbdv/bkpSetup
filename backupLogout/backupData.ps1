param(
    [string]$username = $env:USERNAME
)

# Função para resolver variáveis de ambiente dentro dos caminhos do config.json
function Resolve-PathWithVars {
    param (
        [string]$Path
    )

    # Substituir variáveis de ambiente como $env:USERNAME
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

# Carregar o arquivo de configuração
$config = (Get-Content ".\config.json" -Raw | ConvertFrom-Json).backupSetup

# Resolver os caminhos usando a função Resolve-PathWithVars
$sourcePath = Resolve-PathWithVars $config.sourcePath
$networkPath = Resolve-PathWithVars ($config.networkPath + "\$username")
$backupSetupPath = Resolve-PathWithVars ($config.backupSetupPath -replace "\$env:USERNAME", $username)

# Check if the source directory exists, if not, create it
if (!(Test-Path -Path $sourcePath)) {
    New-Item -ItemType Directory -Path $sourcePath -Force
    Write-Host "Source directory created at $sourcePath"
}

# Check if the network directory exists, if not, create it
if (!(Test-Path -Path $networkPath)) {
    New-Item -ItemType Directory -Path $networkPath -Force
    Write-Host "Network directory created at $networkPath"
}

# Remove existing content ONLY within the BackupSetup folder on the network
if (Test-Path -Path $backupSetupPath) {
    try {
        Remove-Item -Path "$backupSetupPath\*" -Recurse -Force
        Write-Host "Old backup deleted successfully from $backupSetupPath"
    } catch {
        Write-Host "Error during deletion: $_"
    }
}

# Copy the directory
try {
    Copy-Item -Path $sourcePath -Destination $networkPath -Recurse -Force
    Write-Host "Backup completed successfully from $sourcePath to $networkPath"
} catch {
    Write-Host "Error during backup: $_"
}
