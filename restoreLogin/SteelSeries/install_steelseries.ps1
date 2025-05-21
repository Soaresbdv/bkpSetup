Write-Host "`n=======================[ Instalação SteelSeries GG ]=======================" -ForegroundColor Yellow

# Verificar se está rodando como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[ INFO ] Executando como administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Caminho de origem na rede
$networkInstaller = "\\192.168.15.204\pcs\SteelSeries\SteelSeriesGG86.0.0Setup.exe"

# Caminho para a pasta Downloads do usuário logado
$downloadsPath = [Environment]::GetFolderPath("MyDocuments").Replace("Documents", "Downloads")
$localInstaller = Join-Path $downloadsPath "SteelSeriesGG86.0.0Setup.exe"

Write-Host "`n[ INFO ] Copiando instalador para a pasta Downloads..." -ForegroundColor Cyan

try {
    Copy-Item -Path $networkInstaller -Destination $localInstaller -Force
    Write-Host "[ ✅ SUCCESS ] Instalador copiado para: $localInstaller" -ForegroundColor Green
} catch {
    Write-Host "[ ❌ ERROR ] Erro ao copiar o instalador da rede." -ForegroundColor Red
    exit
}

# Executar o instalador
Write-Host "`n[ INFO ] Executando instalador..." -ForegroundColor Cyan
try {
    Start-Process -FilePath $localInstaller -Wait -Verb RunAs
    Write-Host "[ ✅ SUCCESS ] Instalação concluída com sucesso." -ForegroundColor Green
} catch {
    Write-Host "[ ❌ ERROR ] Erro ao executar o instalador." -ForegroundColor Red
    exit
}

Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host "[ ✅ FINALIZADO ] Processo de instalação do SteelSeries GG concluído com sucesso!" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
