Write-Host "`n=======================[ RESTORE MICROSIP ]=======================" -ForegroundColor Yellow

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
$networkBackupPath = "\\192.168.15.204\pcs\fileSystem\userBackup\$userName\MicroSIP"

# Caminho local do MicroSIP
$localMicroSIPPath = Join-Path $userProfile "AppData\Roaming\MicroSIP"

# Verifica se o backup existe
if (!(Test-Path $networkBackupPath)) {
    Write-Host "`n[ ❌ ERROR ] Backup do MicroSIP não encontrado em: $networkBackupPath" -ForegroundColor Red
    exit
}

# Encerra o MicroSIP se estiver rodando
Write-Host "`n[ INFO ] Encerrando processos do MicroSIP..." -ForegroundColor Yellow
Get-Process -Name "microsip" -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove pasta local do MicroSIP (se existir)
Write-Host "`n[ INFO ] Limpando dados locais do MicroSIP..." -ForegroundColor Cyan
try {
    if (Test-Path $localMicroSIPPath) {
        Remove-Item -Path $localMicroSIPPath -Recurse -Force -ErrorAction Stop
        Write-Host "[ OK ] Pasta local do MicroSIP removida." -ForegroundColor Green
    }
} catch {
    Write-Host "[ ⚠️ WARNING ] Não foi possível remover completamente: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Cria pasta de destino se não existir
if (!(Test-Path $localMicroSIPPath)) {
    New-Item -ItemType Directory -Path $localMicroSIPPath | Out-Null
}

# Copia os dados do backup para o local
Write-Host "`n[ INFO ] Restaurando dados do MicroSIP..." -ForegroundColor Cyan
try {
    Copy-Item -Path "$networkBackupPath\*" -Destination $localMicroSIPPath -Recurse -Force -ErrorAction Stop
    Write-Host "[ ✅ SUCCESS ] Dados do MicroSIP restaurados com sucesso para: $localMicroSIPPath" -ForegroundColor Green
} catch {
    Write-Host "[ ❌ ERROR ] Erro ao copiar os dados: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "`n===============================================================================" -ForegroundColor Yellow
Write-Host "[ ✅ FINALIZADO ] Restore do MicroSIP concluído para: $localMicroSIPPath" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Yellow
