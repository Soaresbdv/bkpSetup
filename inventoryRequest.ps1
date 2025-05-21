$configPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) '..\config.json'

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$apiUrl = $config.inventoryRequest.apiUrl
$method = $config.inventoryRequest.method

$username = $env:USERNAME
$hostname = $env:COMPUTERNAME

$body = @{
    method = $method
    filter = @($username, $hostname)
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType 'application/json'
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Error "Request failed: $_"
}
