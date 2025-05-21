Write-Host "`n=======================[ Atualização SteelSeries GG - Configurações ]=======================" -ForegroundColor Yellow

# Verificar se está rodando como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[ INFO ] Executando como administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Caminhos
$networkConfig = "\\192.168.15.204\pcs\SteelSeries\GG"
$localConfig = "C:\ProgramData\SteelSeries\GG"

Write-Host "`n[ INFO ] Iniciando cópia das configurações do SteelSeries GG..." -ForegroundColor Cyan

# Verifica se a pasta da rede existe
if (!(Test-Path $networkConfig)) {
    Write-Host "[ ❌ ERROR ] Pasta de configuração na rede não encontrada: $networkConfig" -ForegroundColor Red
    exit
}

# Encerra todos os processos relacionados ao SteelSeries para evitar bloqueio de arquivos
Write-Host "`n[ INFO ] Encerrando processos do SteelSeries (se existirem)..." -ForegroundColor Yellow
$processList = Get-Process | Where-Object { $_.Name -like "*steel*" }
foreach ($proc in $processList) {
    try {
        Stop-Process -Id $proc.Id -Force -ErrorAction Stop
        Write-Host "[ OK ] Processo $($proc.Name) encerrado." -ForegroundColor Green
    } catch {
        Write-Host "[ INFO ] Não foi possível encerrar $($proc.Name). Pode não estar rodando." -ForegroundColor Gray
    }
}

# Remove a pasta local (se existir)
Write-Host "`n[ INFO ] Limpando configurações locais do SteelSeries GG..." -ForegroundColor Cyan
try {
    if (Test-Path $localConfig) {
        Remove-Item -Path $localConfig -Recurse -Force -ErrorAction Stop
        Write-Host "[ OK ] Configurações locais removidas." -ForegroundColor Green
    } else {
        Write-Host "[ INFO ] Nenhuma configuração local encontrada para remover." -ForegroundColor Gray
    }
} catch {
    Write-Host "[ ⚠️ WARNING ] Não foi possível remover completamente: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Cria a pasta local se não existir
if (!(Test-Path $localConfig)) {
    New-Item -ItemType Directory -Path $localConfig | Out-Null
}

# Copia da rede para local
Write-Host "`n[ INFO ] Copiando configurações da rede para: $localConfig..." -ForegroundColor Cyan
try {
    Copy-Item -Path "$networkConfig\*" -Destination $localConfig -Recurse -Force -ErrorAction Stop
    Write-Host "[ ✅ SUCCESS ] Configurações atualizadas com sucesso." -ForegroundColor Green
} catch {
    Write-Host "[ ❌ ERROR ] Erro ao copiar configurações: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host "[ ✅ FINALIZADO ] Atualização das configurações do SteelSeries GG concluída com sucesso!" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
