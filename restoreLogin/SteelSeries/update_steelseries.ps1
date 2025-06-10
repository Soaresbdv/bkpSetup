Write-Host "`n=======================[ SteelSeries GG Update Process ]=======================" -ForegroundColor Yellow

# Close SteelSeries GG if it's running
Write-Host "`n[ INFO ] Closing SteelSeries GG if running..." -ForegroundColor Cyan

# Tentando fechar todos os processos relacionados ao SteelSeries GG
$processes = Get-Process | Where-Object { $_.ProcessName -like "SteelSeries*" }

if ($processes) {
    foreach ($process in $processes) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            Write-Host "[ SUCCESS ] Process '$($process.Name)' (PID: $($process.Id)) closed successfully." -ForegroundColor Green
        } catch {
            Write-Host "[ WARNING ] Failed to close process '$($process.Name)' (PID: $($process.Id))." -ForegroundColor Yellow
        }
    }
}

# Espera adicional para garantir que todos os processos sejam fechados completamente
Start-Sleep -Seconds 5

# Verificação se o processo ainda está ativo após tentativa de encerramento
$stillRunning = Get-Process | Where-Object { $_.ProcessName -like "SteelSeries*" }
if ($stillRunning) {
    Write-Host "[ ERROR ] Some SteelSeries GG processes are still running. Update cannot proceed." -ForegroundColor Red
    exit
} else {
    Write-Host "[ SUCCESS ] All SteelSeries GG processes have been closed successfully." -ForegroundColor Green
}

$projectRoot = (Get-Item "$PSScriptRoot\..\..").FullName
$configPath = Join-Path $projectRoot "config.json"

if (!(Test-Path $configPath)) {
    Write-Host "`n[ ERROR ] Configuration file not found." -ForegroundColor Red
    exit
}

$config = Get-Content $configPath | ConvertFrom-Json
$networkFolder = $config.steelseries.networkFolder
$destinationFolder = $config.steelseries.destinationFolder

Write-Host "`n[ INFO ] Checking network folder..." -ForegroundColor Cyan
if (!(Test-Path $networkFolder)) {
    Write-Host "[ ERROR ] Network folder not found." -ForegroundColor Red
    exit
}

Write-Host "[ SUCCESS ] Network folder located. Proceeding with update." -ForegroundColor Green

if (Test-Path $destinationFolder) {
    Write-Host "`n[ INFO ] Deleting old folder..." -ForegroundColor Yellow
    try {
        Remove-Item -Path $destinationFolder -Recurse -Force
        Write-Host "[ SUCCESS ] Old folder removed." -ForegroundColor Green
    } catch {
        Write-Host "[ ERROR ] Failed to remove the folder. It might still be in use." -ForegroundColor Red
        exit
    }
}

Write-Host "`n[ INFO ] Copying network folder to local destination..." -ForegroundColor Cyan
try {
    Copy-Item -Path $networkFolder -Destination $destinationFolder -Recurse -Force
    Write-Host "[ SUCCESS ] Copy operation completed successfully." -ForegroundColor Green
} catch {
    Write-Host "[ ERROR ] Failed to copy the folder." -ForegroundColor Red
    exit
}

Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host "[ SUCCESS ] Update process completed successfully!" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
