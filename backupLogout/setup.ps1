# Caminho da pasta onde está este script (já dentro de backupLogout)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Scripts estão na mesma pasta
$chromeBackupScript     = Join-Path $scriptDir "backupChrome.ps1"
$dataBackupScript       = Join-Path $scriptDir "backupData.ps1"
$microsipBackupScript   = Join-Path $scriptDir "backupMicrosip.ps1"

# Rodar Data Backup
Write-Host "Running Data Backup Script..." -ForegroundColor Cyan
try {
    & $dataBackupScript
    Write-Host "Data backup completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running Data backup script: $_" -ForegroundColor Red
}

# Rodar Chrome Backup
Write-Host "Running Chrome Backup Script..." -ForegroundColor Cyan
try {
    & $chromeBackupScript
    Write-Host "Chrome backup completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running Chrome backup script: $_" -ForegroundColor Red
}

# Rodar MicroSIP Backup
Write-Host "Running MicroSIP Backup Script..." -ForegroundColor Cyan
try {
    & $microsipBackupScript
    Write-Host "MicroSIP backup completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error running MicroSIP backup script: $_" -ForegroundColor Red
}

Write-Host "All backup processes completed." -ForegroundColor Green
