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

$endTime = Get-Date
$totalTime = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "Ecosistema iniciado!" -ForegroundColor Green
Write-Host "Tiempo total: $totalTime segundos" -ForegroundColor Green
Write-Host ""
Write-Host "URLs disponibles:" -ForegroundColor Cyan
Write-Host "  - Eureka Dashboard: http://localhost:8761" -ForegroundColor White
Write-Host "  - API Gateway:      http://localhost:9090" -ForegroundColor White
Write-Host "  - Config Server:    http://localhost:9296" -ForegroundColor White
Write-Host "  - Zipkin Tracing:   http://localhost:9411" -ForegroundColor White
Write-Host ""
Write-Host "Estado de servicios:" -ForegroundColor Cyan
docker-compose ps
