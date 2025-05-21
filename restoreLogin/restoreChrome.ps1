Write-Host "`n=======================[ RESTORE GOOGLE CHROME - CONTEÚDO DE PROFILE ]=======================" -ForegroundColor Yellow

# Verifica se está sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[ INFO ] Reabrindo script com privilégios de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Nome do usuário logado
$userName = $env:USERNAME
$userProfile = $env:USERPROFILE

# Caminho do backup no servidor
$networkBackupPath = "\\192.168.15.204\pcs\fileSystem\userBackup\$userName\chrome"

# Caminho de destino local
$chromeProfilePath = Join-Path $userProfile "AppData\Local\Google\Chrome\User Data\Profile 1"

# Verifica se o backup existe
if (!(Test-Path $networkBackupPath)) {
    Write-Host "`n[ ❌ ERROR ] Backup do Chrome não encontrado em: $networkBackupPath" -ForegroundColor Red
    exit
}

# Encerra o Chrome
Write-Host "`n[ INFO ] Encerrando processos do Google Chrome..." -ForegroundColor Yellow
Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove perfil local (se existir)
Write-Host "`n[ INFO ] Limpando perfil local (Profile 1)..." -ForegroundColor Cyan
try {
    if (Test-Path $chromeProfilePath) {
        Remove-Item -Path $chromeProfilePath -Recurse -Force -ErrorAction Stop
        Write-Host "[ OK ] Perfil local removido." -ForegroundColor Green
    }
} catch {
    Write-Host "[ ⚠️ WARNING ] Não foi possível remover completamente: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Cria pasta de destino se não existir
if (!(Test-Path $chromeProfilePath)) {
    New-Item -ItemType Directory -Path $chromeProfilePath | Out-Null
}

# Copia todo o conteúdo do backup diretamente para a pasta Profile 1
Write-Host "`n[ INFO ] Restaurando dados do Chrome (conteúdo) para Profile 1..." -ForegroundColor Cyan
try {
    Copy-Item -Path "$networkBackupPath\*" -Destination $chromeProfilePath -Recurse -Force -ErrorAction Stop
    Write-Host "[ ✅ SUCCESS ] Dados restaurados com sucesso para: $chromeProfilePath" -ForegroundColor Green
} catch {
    Write-Host "[ ❌ ERROR ] Erro ao copiar os dados: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "`n===============================================================================" -ForegroundColor Yellow
Write-Host "[ ✅ FINALIZADO ] Restore do Chrome concluído para: $chromeProfilePath" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
