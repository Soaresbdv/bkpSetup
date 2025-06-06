# restoreMicrosip.ps1

# Carrega o config.json e converte para objeto Microsip
$config = (Get-Content (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\\config.json") -Raw | ConvertFrom-Json).microsip

# Resolve variáveis de ambiente no caminho
function Resolve-PathWithVars {
    param ([string]$Path)
    return $ExecutionContext.InvokeCommand.ExpandString($Path)
}

# Variáveis de caminho
$username = $env:USERNAME
$sourceBase = Resolve-PathWithVars $config.networkPath
$sourcePath = Join-Path (Join-Path $sourceBase $username) "microsip"
$destinationPath = Resolve-PathWithVars $config.sourcePath

Write-Host "Restaurando arquivos do MicroSIP de $sourcePath para $destinationPath" -ForegroundColor Cyan

# Garante que o destino existe
if (-not (Test-Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

# Sempre retorna arrays, mesmo que haja um só item
$filesToRestore = @()
$filesToRestore += @(Get-ChildItem -Path $sourcePath -Filter *.ini -File -ErrorAction SilentlyContinue)
$filesToRestore += @(Get-ChildItem -Path $sourcePath -Filter *.edge -File -ErrorAction SilentlyContinue)

$failedCopies = @()

foreach ($file in $filesToRestore) {
    $destinationFile = Join-Path $destinationPath $file.Name
    try {
        Copy-Item -Path $file.FullName -Destination $destinationFile -Force
        Write-Host "Restaurado: $($file.Name)"
    } catch {
        $failedCopies += $file.FullName
    }
}

# Resultado final
if ($failedCopies.Count -gt 0) {
    Write-Host "`nFalha ao restaurar os seguintes arquivos:" -ForegroundColor Yellow
    $failedCopies | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "`nRestauro do MicroSIP concluído com sucesso!" -ForegroundColor Green
}
