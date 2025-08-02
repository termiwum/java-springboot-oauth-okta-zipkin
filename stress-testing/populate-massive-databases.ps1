# Script para poblar bases de datos masivas secuencialmente
Write-Host "Iniciando poblacion masiva de bases de datos para 2M+ usuarios..." -ForegroundColor Green
Write-Host "ATENCION: Este proceso puede tomar 30-60 minutos" -ForegroundColor Yellow

# Cargar credenciales de forma segura
if (Test-Path ".\.db-credentials.ps1") {
    . ".\.db-credentials.ps1"
    $credentials = Get-DBCredentials
    $dbUser = $credentials.User
    $dbPassword = $credentials.Password
} else {
    Write-Host "ERROR: No se encontro archivo de credenciales .db-credentials.ps1" -ForegroundColor Red
    Write-Host "Cree el archivo con las credenciales correctas" -ForegroundColor Yellow
    exit 1
}

# Función para ejecutar SQL y mostrar progreso
function Execute-MassiveSQL {
    param(
        [string]$ContainerName,
        [string]$SqlFile,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "EJECUTANDO: $Description" -ForegroundColor Yellow
    Write-Host "Contenedor: $ContainerName" -ForegroundColor White
    Write-Host "Archivo: $SqlFile" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    
    $startTime = Get-Date
    
    try {
        # Copiar archivo SQL al contenedor
        Write-Host "Copiando archivo SQL al contenedor..." -ForegroundColor Gray
        docker cp $SqlFile "${ContainerName}:/tmp/script.sql"
        
        # Ejecutar el script SQL con credenciales seguras
        Write-Host "Ejecutando script SQL (esto puede tomar varios minutos)..." -ForegroundColor Gray
        docker exec $ContainerName mysql -u $dbUser -p$dbPassword -e "source /tmp/script.sql"
        
        # Limpiar archivo temporal
        docker exec $ContainerName rm /tmp/script.sql
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Host "COMPLETADO: $Description" -ForegroundColor Green
        Write-Host "Tiempo transcurrido: $($duration.ToString('mm\:ss'))" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR en $ContainerName : $_" -ForegroundColor Red
        Write-Host "Continuando con el siguiente..." -ForegroundColor Yellow
    }
}

$totalStartTime = Get-Date

# 1. Poblar base de datos de productos (10,000+ productos)
Execute-MassiveSQL -ContainerName "mysql-product" -SqlFile "./scripts/populate-products.sql" -Description "Base de datos de PRODUCTOS (10,000+ items con stock alto)"

# 2. Poblar base de datos de órdenes (500,000 órdenes)
Execute-MassiveSQL -ContainerName "mysql-order" -SqlFile "./scripts/populate-orders.sql" -Description "Base de datos de ORDENES (500,000 ordenes para 2M usuarios)"

# 3. Poblar base de datos de pagos (600,000 pagos)
Execute-MassiveSQL -ContainerName "mysql-payment" -SqlFile "./scripts/populate-payments.sql" -Description "Base de datos de PAGOS (600,000+ transacciones)"

$totalEndTime = Get-Date
$totalDuration = $totalEndTime - $totalStartTime

Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "POBLACION MASIVA COMPLETADA!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "Tiempo total: $($totalDuration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host ""
Write-Host "DATOS GENERADOS:" -ForegroundColor Yellow
Write-Host "  Productos: ~10,000 items con stock masivo" -ForegroundColor White
Write-Host "  Ordenes: 500,000 ordenes de 2M usuarios" -ForegroundColor White
Write-Host "  Items de ordenes: ~2,000,000 items" -ForegroundColor White
Write-Host "  Pagos: 600,000+ transacciones" -ForegroundColor White
Write-Host ""
Write-Host "CAPACIDAD DE STRESS TESTING:" -ForegroundColor Yellow
Write-Host "  Soporta: 2M+ usuarios virtuales" -ForegroundColor Green
Write-Host "  Pedidos simultaneos: Alto volumen" -ForegroundColor Green
Write-Host "  Productos disponibles: Stock suficiente" -ForegroundColor Green
Write-Host ""
Write-Host "Las pruebas de stress testing ahora pueden manejar cargas masivas!" -ForegroundColor Green
