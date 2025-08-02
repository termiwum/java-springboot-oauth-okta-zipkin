# Script para importar todos los dashboards de K6 en Grafana
Write-Host "Importando dashboards de K6 en Grafana..." -ForegroundColor Green

# URL base de Grafana
$grafanaUrl = "http://localhost:3000"
$grafanaUser = "admin"
$grafanaPassword = "admin"

# Crear credenciales base64
$credentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${grafanaUser}:${grafanaPassword}"))

# Headers para las peticiones
$headers = @{
    "Authorization" = "Basic $credentials"
    "Content-Type" = "application/json"
}

# Función para importar un dashboard
function Import-Dashboard {
    param(
        [string]$DashboardFile,
        [string]$DashboardName
    )
    
    try {
        Write-Host "Importando dashboard: $DashboardName" -ForegroundColor Yellow
        
        # Leer el archivo JSON del dashboard
        $dashboardJson = Get-Content $DashboardFile -Raw | ConvertFrom-Json
        
        # Crear el payload para la API de Grafana
        $importPayload = @{
            dashboard = $dashboardJson
            overwrite = $true
            inputs = @()
        } | ConvertTo-Json -Depth 10
        
        # Realizar la petición de importación
        $response = Invoke-RestMethod -Uri "$grafanaUrl/api/dashboards/db" -Method POST -Headers $headers -Body $importPayload
        
        Write-Host "✅ Dashboard '$DashboardName' importado correctamente" -ForegroundColor Green
        Write-Host "   URL: $grafanaUrl/d/$($dashboardJson.uid)" -ForegroundColor Gray
    }
    catch {
        Write-Host "❌ Error importando dashboard '$DashboardName': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Verificar que Grafana esté disponible
try {
    Write-Host "Verificando conexión con Grafana..." -ForegroundColor Gray
    $healthCheck = Invoke-RestMethod -Uri "$grafanaUrl/api/health" -Method GET
    Write-Host "✅ Grafana está disponible" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: No se puede conectar con Grafana en $grafanaUrl" -ForegroundColor Red
    Write-Host "Asegúrese de que Grafana esté ejecutándose" -ForegroundColor Yellow
    exit 1
}

# Dashboards a importar
$dashboards = @(
    @{
        File = ".\dashboards\ecosystem-global-dashboard.json"
        Name = "Ecosystem Global Dashboard"
    },
    @{
        File = ".\dashboards\product-service-dashboard.json"
        Name = "Product Service Dashboard"
    },
    @{
        File = ".\dashboards\payment-service-dashboard.json"
        Name = "Payment Service Dashboard"
    },
    @{
        File = ".\dashboards\order-place-dashboard.json"
        Name = "Order Place Dashboard"
    },
    @{
        File = ".\dashboards\order-details-dashboard.json"
        Name = "Order Details Dashboard"
    },
    @{
        File = ".\monitoring-config\grafana\dashboards\k6-auto-dashboard.json"
        Name = "K6 Auto Dashboard"
    },
    @{
        File = ".\monitoring-config\grafana\dashboards\k6-simple-dashboard.json"
        Name = "K6 Simple Dashboard"
    },
    @{
        File = ".\monitoring-config\grafana\dashboards\k6-prometheus-dashboard.json"
        Name = "K6 Prometheus Dashboard"
    }
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORTANDO DASHBOARDS DE K6" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

# Importar cada dashboard
foreach ($dashboard in $dashboards) {
    if (Test-Path $dashboard.File) {
        Import-Dashboard -DashboardFile $dashboard.File -DashboardName $dashboard.Name
    } else {
        Write-Host "⚠️  Archivo no encontrado: $($dashboard.File)" -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORTACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboards disponibles en Grafana:" -ForegroundColor White
Write-Host "• Ecosystem Global: $grafanaUrl/d/ecosystem-global" -ForegroundColor Gray
Write-Host "• Product Service: $grafanaUrl/d/product-service" -ForegroundColor Gray
Write-Host "• Payment Service: $grafanaUrl/d/payment-service" -ForegroundColor Gray
Write-Host "• Order Place: $grafanaUrl/d/order-place" -ForegroundColor Gray
Write-Host "• Order Details: $grafanaUrl/d/order-details" -ForegroundColor Gray
Write-Host "• K6 Auto: $grafanaUrl/d/k6-auto" -ForegroundColor Gray
Write-Host "• K6 Simple: $grafanaUrl/d/k6-simple" -ForegroundColor Gray
Write-Host "• K6 Prometheus: $grafanaUrl/d/k6-prometheus" -ForegroundColor Gray
Write-Host ""
Write-Host "Los dashboards estan listos para monitorear las pruebas de estres" -ForegroundColor Green
