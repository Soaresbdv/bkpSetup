# === Get Environment Variables ===
$username = $env:USERNAME
$hostname = $env:COMPUTERNAME

# === Create JSON Body ===
$body = @{
    method = "compare"
    filter = @($username, $hostname)
} | ConvertTo-Json -Depth 2

# === Define Endpoint ===
$uri = "http://gwinterno.setuptecnologia.com/inventory/api""

# === Send POST Request ===
try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/json"

    Write-Host "=== API Response ==="
    $response | ConvertTo-Json -Depth 4 | Write-Output
}
catch {
    Write-Host "=== ERROR ==="
    Write-Host $_.Exception.Message
}
