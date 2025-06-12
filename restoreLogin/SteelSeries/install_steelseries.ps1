# Caminho fixo do instalador na rede
$installerPath = "\\192.168.15.204\pcs\SteelSeries\SteelSeriesGG88.0.0Setup.exe"

# Função para verificar se o SteelSeries já está em execução (indicando que está instalado)
function Is-SteelSeriesInstalled {
    return (Get-Process -Name "SteelSeriesGG" -ErrorAction SilentlyContinue) -ne $null
}

# Se já estiver instalado, sai sem fazer nada
if (Is-SteelSeriesInstalled) {
    Write-Host "✅ SteelSeries já está instalado. Encerrando script."
    exit
}

# Verifica se o instalador existe no caminho de rede
if (!(Test-Path -Path $installerPath)) {
    Write-Host "❌ Instalador não encontrado em: $installerPath"
    exit
}

# Copia o instalador para a pasta Downloads local
$downloadsPath = "$env:USERPROFILE\Downloads"
$localInstaller = Join-Path $downloadsPath ([System.IO.Path]::GetFileName($installerPath))
Copy-Item -Path $installerPath -Destination $localInstaller -Force

# Executa o instalador em modo silencioso
Write-Host "🚀 Iniciando instalação do SteelSeries GG..."
Start-Process -FilePath $localInstaller -ArgumentList "/S" -WindowStyle Hidden -Wait
Write-Host "✅ Instalação finalizada."
