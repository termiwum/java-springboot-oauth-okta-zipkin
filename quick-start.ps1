# Script optimizado de arranque completo del ecosistema - PowerShell
# Optimizaciones aplicadas para reducir tiempos de inicio

Write-Host "Iniciando ecosistema de microservicios optimizado..." -ForegroundColor Green

# Fase 1: Construir en paralelo todas las imagenes
Write-Host "Fase 1: Construyendo imagenes en paralelo..." -ForegroundColor Yellow
$startTime = Get-Date

# Construir imagenes en paralelo para acelerar el proceso
docker-compose build --parallel --no-cache

$buildTime = Get-Date
$buildDuration = ($buildTime - $startTime).TotalSeconds
Write-Host "Imagenes construidas en $buildDuration segundos" -ForegroundColor Green

# Fase 2: Iniciar infraestructura basica
Write-Host "Fase 2: Iniciando infraestructura basica..." -ForegroundColor Yellow
docker-compose up -d redis zipkin mysql-product mysql-payment mysql-order

# Esperar a que las bases de datos esten listas
Write-Host "Esperando bases de datos..." -ForegroundColor Yellow
$timeout = 60
do {
    $healthyCount = (docker-compose ps | Select-String -Pattern "(mysql.*healthy|redis.*healthy|zipkin.*healthy)").Count
    if ($healthyCount -ge 4) {
        break
    }
    Write-Host "Esperando infraestructura... $timeout s restantes" -ForegroundColor Cyan
    Start-Sleep 5
    $timeout -= 5
} while ($timeout -gt 0)

# Fase 3: Iniciar servicios core
Write-Host "Fase 3: Iniciando servicios core..." -ForegroundColor Yellow
docker-compose up -d service-registry
Start-Sleep 15  # Dar tiempo al service registry

docker-compose up -d config-server
Start-Sleep 10  # Dar tiempo al config server

# Fase 4: Iniciar servicios de negocio en paralelo
Write-Host "Fase 4: Iniciando servicios de negocio..." -ForegroundColor Yellow
docker-compose up -d product-service payment-service order-service

# Fase 5: Iniciar API Gateway
Write-Host "Fase 5: Iniciando API Gateway..." -ForegroundColor Yellow
Start-Sleep 20  # Esperar a que los servicios se registren
docker-compose up -d cloud-gateway

# Fase 6: Iniciar stack de monitoreo
Write-Host "Fase 6: Iniciando stack de monitoreo..." -ForegroundColor Yellow
cd stress-testing
docker-compose -f docker-compose-monitoring.yml up -d
cd ..
Write-Host "Esperando que Grafana esté completamente listo..." -ForegroundColor Gray
Start-Sleep 30  # Esperar más tiempo que Grafana esté listo

# Fase 7: Importar dashboards de Grafana
Write-Host "Fase 7: Importando dashboards de Grafana..." -ForegroundColor Yellow

# Verificar que Grafana responda antes de importar
$grafanaReady = $false
$attempts = 0
$maxAttempts = 10

while (-not $grafanaReady -and $attempts -lt $maxAttempts) {
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -Method GET -TimeoutSec 5
        $grafanaReady = $true
        Write-Host "✅ Grafana está listo" -ForegroundColor Green
    } catch {
        $attempts++
        Write-Host "Esperando que Grafana responda... (intento $attempts/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep 5
    }
}

if ($grafanaReady) {
    try {
        cd stress-testing
        & ".\import-dashboards-fixed.ps1"
        cd ..
        Write-Host "✅ Dashboards importados correctamente" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Error importando dashboards: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Continuando con el startup..." -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️ Grafana no respondió a tiempo, saltando importación de dashboards" -ForegroundColor Yellow
}

$endTime = Get-Date
$totalTime = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "🎉 Ecosistema completamente iniciado!" -ForegroundColor Green
Write-Host "Tiempo total: $totalTime segundos" -ForegroundColor Green
Write-Host ""
Write-Host "URLs disponibles:" -ForegroundColor Cyan
Write-Host "  - Eureka Dashboard: http://localhost:8761" -ForegroundColor White
Write-Host "  - API Gateway:      http://localhost:9090" -ForegroundColor White
Write-Host "  - Config Server:    http://localhost:9296" -ForegroundColor White
Write-Host "  - Zipkin Tracing:   http://localhost:9411" -ForegroundColor White
Write-Host "  - Grafana (admin/admin): http://localhost:3000" -ForegroundColor White
Write-Host "  - InfluxDB:         http://localhost:8087" -ForegroundColor White
Write-Host ""
Write-Host "Estado de servicios:" -ForegroundColor Cyan
docker-compose ps
