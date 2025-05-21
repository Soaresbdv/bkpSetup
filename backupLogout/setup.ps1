# Define the paths to the backup scripts located in the "backup" folder
$chromeBackupScript = ".\backupLogout\backupChrome.ps1"
$microsipBackupScript = ".\backupLogout\backupMicrosip.ps1"
$dataBackupScript = ".\backupLogout\backupData.ps1"

# Run Data Backup Script (backupData.ps1)
Write-Host "Running Data Backup Script..." -ForegroundColor Cyan
try {
    & $dataBackupScript
    Write-Host "Data backup completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error running Data backup script: $_" -ForegroundColor Red
}

# Run Chrome Backup Script (backupChrome.ps1)
Write-Host "Running Chrome Backup Script..." -ForegroundColor Cyan
try {
    & $chromeBackupScript
    Write-Host "Chrome backup completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error running Chrome backup script: $_" -ForegroundColor Red
}

# Run MicroSIP Backup Script (backupMicrosip.ps1)
Write-Host "Running MicroSIP Backup Script..." -ForegroundColor Cyan
try {
    & $microsipBackupScript
    Write-Host "MicroSIP backup completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error running MicroSIP backup script: $_" -ForegroundColor Red
}

Write-Host "All backup processes completed." -ForegroundColor Green
