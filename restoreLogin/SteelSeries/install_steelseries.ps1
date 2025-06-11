# Caminho do instalador
$installerName = "SteelSeriesGG88.0.0Setup.exe"
$downloadsPath = "$env:USERPROFILE\Downloads"
$installerPath = Join-Path $downloadsPath $installerName

# Função para verificar se o SteelSeries está instalado (simplesmente verifica processo ativo)
function Is-SteelSeriesInstalled {
    return (Get-Process -Name "SteelSeriesGG" -ErrorAction SilentlyContinue) -ne $null
}

# Se já estiver instalado, sai sem fazer nada
if (Is-SteelSeriesInstalled) {
    Write-Host "SteelSeries já está instalado. Encerrando script."
    exit
}

# Verifica se o instalador já está na pasta Downloads
if (!(Test-Path -Path $installerPath)) {
    # O instalador não está em Downloads, então copia (assumindo que o original esteja junto ao script)
    $sourcePath = Join-Path $PSScriptRoot $installerName
    if (Test-Path -Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $downloadsPath
    } else {
        Write-Host "Arquivo de instalação não encontrado no diretório do script."
        exit
    }
}

# Executa o instalador silenciosamente, sem mostrar janela do PowerShell
Start-Process -FilePath $installerPath -ArgumentList "/S" -WindowStyle Hidden
