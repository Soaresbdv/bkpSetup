Write-Host "`n=======================[ Setup SteelSeries GG - Automação ]=======================" -ForegroundColor Yellow

# Verifica se está rodando como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[ INFO ] Reabrindo com privilégios de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define caminhos relativos ao script atual
$scriptRoot = $PSScriptRoot
$installScript = Join-Path $scriptRoot "install_steelseries.ps1"
$updateScript = Join-Path $scriptRoot "update_steelseries.ps1"

# Verifica e executa o install_steelseries.ps1
try {
    & $installScript
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        Write-Host "[ ⚠️ AVISO ] Script de instalação retornou código $exitCode. Verifique se houve falhas reais." -ForegroundColor Yellow
    } else {
        Write-Host "[ ✅ OK ] Instalação concluída." -ForegroundColor Green
    }
} catch {
    Write-Host "[ ❌ ERROR ] Falha ao executar install_steelseries.ps1." -ForegroundColor Red
    exit
} else {
    Write-Host "[ ❌ ERROR ] Script de instalação não encontrado em: $installScript" -ForegroundColor Red
    exit
}

# Verifica e executa o update_steelseries.ps1
if (Test-Path $updateScript) {
    Write-Host "`n[ INFO ] Atualizando configurações padrão do SteelSeries GG..." -ForegroundColor Cyan
    try {
        & $updateScript
        Write-Host "[ ✅ OK ] Atualização concluída." -ForegroundColor Green
    } catch {
        Write-Host "[ ❌ ERROR ] Falha ao executar update_steelseries.ps1." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "[ ❌ ERROR ] Script de update não encontrado em: $updateScript" -ForegroundColor Red
    exit
}

Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host "[ ✅ FINALIZADO ] Setup do SteelSeries concluído com sucesso!" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
