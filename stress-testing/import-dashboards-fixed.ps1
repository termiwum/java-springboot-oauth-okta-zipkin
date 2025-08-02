# Script para importar dashboards en Grafana
Write-Host "Importando dashboards en Grafana..." -ForegroundColor Green

$grafanaUrl = "http://localhost:3000"
$credentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("admin:grafana123"))
$headers = @{
    "Authorization" = "Basic $credentials"
    "Content-Type" = "application/json"
}

function Import-Dashboard {
    param([string]$File, [string]$Name)
    
    try {
        Write-Host "Importando: $Name" -ForegroundColor Yellow
        $json = Get-Content $File -Raw | ConvertFrom-Json
        $payload = @{dashboard = $json; overwrite = $true} | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "$grafanaUrl/api/dashboards/db" -Method POST -Headers $headers -Body $payload
        Write-Host "OK: $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: $Name - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Verificar Grafana
try {
    $health = Invoke-RestMethod -Uri "$grafanaUrl/api/health" -Method GET
    Write-Host "Grafana OK" -ForegroundColor Green
}
catch {
    Write-Host "Grafana no disponible" -ForegroundColor Red
    exit 1
}

# Importar dashboards
$dashboards = @(
    @{File = ".\dashboards\ecosystem-global-dashboard.json"; Name = "Ecosystem Global"},
    @{File = ".\dashboards\product-service-dashboard.json"; Name = "Product Service"},
    @{File = ".\dashboards\payment-service-dashboard.json"; Name = "Payment Service"},
    @{File = ".\dashboards\order-place-dashboard.json"; Name = "Order Place"},
    @{File = ".\dashboards\order-details-dashboard.json"; Name = "Order Details"},
    @{File = ".\monitoring-config\grafana\dashboards\k6-auto-dashboard.json"; Name = "K6 Auto"},
    @{File = ".\monitoring-config\grafana\dashboards\k6-simple-dashboard.json"; Name = "K6 Simple"},
    @{File = ".\monitoring-config\grafana\dashboards\k6-prometheus-dashboard.json"; Name = "K6 Prometheus"}
)

foreach ($dashboard in $dashboards) {
    if (Test-Path $dashboard.File) {
        Import-Dashboard -File $dashboard.File -Name $dashboard.Name
    } else {
        Write-Host "Archivo no encontrado: $($dashboard.File)" -ForegroundColor Yellow
    }
}

Write-Host "Importacion completada" -ForegroundColor Green
